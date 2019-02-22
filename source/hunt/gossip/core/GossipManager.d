// Copyright (c) 2017 The jgossip Authors. All rights reserved.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

module hunt.gossip.core.GossipManager;

import hunt.gossip.util.Buffer;
import std.json;

import hunt.logging;
import hunt.gossip.event.GossipListener;
import hunt.gossip.model.Ack2Message;
import hunt.gossip.model.AckMessage;
import hunt.gossip.model.CandidateMemberState;
import hunt.gossip.model.GossipDigest;
import hunt.gossip.model.GossipMember;
import hunt.gossip.model.GossipState;
import hunt.gossip.model.HeartbeatState;
import hunt.gossip.model.MessageType;
import hunt.gossip.model.SeedMember;
import hunt.gossip.core.GossipMessageFactory;

// import java.net.UnknownHostException;
import hunt.collection.ArrayList;
import hunt.collection.Collections;
import hunt.collection.List;
import hunt.collection.Map;
import std.random;
import hunt.collection.Set;
import hunt.collection.HashMap;
import hunt.concurrency.Executors;
import hunt.concurrency.ScheduledExecutorService;
import hunt.util.DateTime;
// import hunt.concurrency.locks.ReentrantReadWriteLock;
import core.sync.rwmutex;
import hunt.gossip.util.JsonObject;
import hunt.gossip.core.GossipSettings;
import hunt.Integer;
import hunt.util.Common;
import hunt.gossip.core.Serializer;
import hunt.util.DateTime;
import std.conv;
import hunt.Exceptions;

public class GossipManager {
    // private static final Logger LOGGER = LoggerFactory.getLogger(GossipManager.class);
    private static GossipManager instance;
    private long executeGossipTime = 500;
    private bool _isWorking = false;
    // private ReentrantReadWriteLock rwlock = new ReentrantReadWriteLock();
    private ReadWriteMutex rwlock;
    private ScheduledExecutorService doGossipExecutor;
//    private ScheduledExecutorService clearExecutor = Executors.newSingleThreadScheduledExecutor();

    private Map!(GossipMember, HeartbeatState) endpointMembers ;
    private List!(GossipMember) liveMembers;
    private List!(GossipMember) deadMembers;
    private Map!(GossipMember, CandidateMemberState) candidateMembers;
    private GossipSettings settings;
    private GossipMember localGossipMember;
    private string cluster;
    private GossipListener listener;
    private Random random;

    private this() {
        rwlock = new ReadWriteMutex();
        doGossipExecutor = Executors.newScheduledThreadPool(1);
        endpointMembers = new HashMap!(GossipMember, HeartbeatState)();
        liveMembers = new ArrayList!(GossipMember)();
        deadMembers = new ArrayList!(GossipMember)();
        candidateMembers = new HashMap!(GossipMember, CandidateMemberState)();
    }

    public static GossipManager getInstance() {
        if(instance is null)
        {
            instance = new GossipManager();
        }
        return instance;
    }

    public void init(string cluster, string ipAddress, Integer port, string id, List!(SeedMember) seedMembers, GossipSettings settings, GossipListener listener) {
        this.cluster = cluster;
        this.localGossipMember = new GossipMember();
        this.localGossipMember.setCluster(cluster);
        this.localGossipMember.setIpAddress(ipAddress);
        this.localGossipMember.setPort(port);
        this.localGossipMember.setId(id);
        this.localGossipMember.setState(GossipState.JOIN);
        this.endpointMembers.put(localGossipMember, new HeartbeatState());
        this.listener = listener;
        this.settings = settings;
        this.settings.setSeedMembers(seedMembers);
        fireGossipEvent(localGossipMember, GossipState.JOIN);
    }

    public  void start() {
        logInfo("Starting gossip! cluster[%s] ip[%s] port[%d] id[%s]", localGossipMember.getCluster(), localGossipMember.getIpAddress(), localGossipMember.getPort(), localGossipMember.getId());
        _isWorking = true;
        settings.getMsgService().listen(getSelf().getIpAddress(), getSelf().getPort().intValue);
        doGossipExecutor.scheduleAtFixedRate(new GossipTask(), settings.getGossipInterval(), settings.getGossipInterval(), TimeUnit.Millisecond);
    }

    public List!(GossipMember) getLiveMembers() {
        return liveMembers;
    }

    public List!(GossipMember) getDeadMembers() {
        return deadMembers;
    }

    public GossipSettings getSettings() {
        return settings;
    }

    public GossipMember getSelf() {
        return localGossipMember;
    }

    public string getID() {
        return getSelf().getId();
    }

    public bool isWorking() {
        return _isWorking;
    }

    public Map!(GossipMember, HeartbeatState) getEndpointMembers() {
        return endpointMembers;
    }

    public string getCluster() {
        return cluster;
    }

    private void randomGossipDigest(List!(GossipDigest) digests) /* throws UnknownHostException */ {
        GossipMember[] gms;
        foreach(GossipMember k , HeartbeatState v ; endpointMembers)
        {
            gms ~= k;
        }
        // List!(GossipMember) endpoints = new ArrayList!(GossipMember)(gms);
        randomShuffle(gms);
        foreach(GossipMember ep ; gms) {
            HeartbeatState hb = endpointMembers.get(ep);
            long hbTime = 0;
            long hbVersion = 0;
            if (hb !is null) {
                hbTime = hb.getHeartbeatTime();
                hbVersion = hb.getVersion();
            }
            digests.add(new GossipDigest(ep, hbTime, hbVersion));
        }
    }

    class GossipTask : Runnable {

        override
        public void run() {
            //Update local member version
            long newversion = endpointMembers.get(getSelf()).updateVersion();
            if (isDiscoverable(getSelf())) {
                up(getSelf());
            }
            version(HUNT_DEBUG) {
                trace("sync data");
                trace("Now my heartbeat version is %d", newversion);
            }

            List!(GossipDigest) digests = new ArrayList!(GossipDigest)();
            try {
                randomGossipDigest(digests);
                if (digests.size() > 0) {
                    Buffer syncMessageBuffer = encodeSyncMessage(digests);
                    //step 1. goosip to a random live member
                    bool b = gossip2LiveMember(syncMessageBuffer);

                    //step 2. goosip to a random dead memeber
                    gossip2UndiscoverableMember(syncMessageBuffer);

                    //step3.
                    if (!b || liveMembers.size() <= settings.getSeedMembers().size()) {
                        gossip2Seed(syncMessageBuffer);
                    }

                }
                checkStatus();
                version(HUNT_DEBUG) {
                    trace("live member : " ~ getLiveMembers().toString);
                    trace("dead member : " ~ getDeadMembers().toString);
                    trace("endpoint : " ~ getEndpointMembers().toString);
                }
            } catch (Throwable e) {
                logError(e.msg);
            }

        }
    }

    private Buffer encodeSyncMessage(List!(GossipDigest) digests) {
        Buffer buffer = Buffer.buffer();
        JSONValue[] array ;
        foreach(GossipDigest e ; digests) {
            array ~= e.encode()/* JSONValue(Serializer.getInstance().encode!(GossipDigest)(e).toString()) */;
        }
        buffer.appendString(GossipMessageFactory.getInstance().makeMessage(MessageType.SYNC_MESSAGE, JSONValue(array).toString, getCluster(), getSelf().ipAndPort()).encode());
        return buffer;
    }

    public Buffer encodeAckMessage(AckMessage ackMessage) {
        Buffer buffer = Buffer.buffer();
        JsonObject ackJson = JsonObject.mapFrom(ackMessage);
        buffer.appendString(GossipMessageFactory.getInstance().makeMessage(MessageType.ACK_MESSAGE, ackJson.encode(), getCluster(), getSelf().ipAndPort()).encode());
        return buffer;
    }

    public Buffer encodeAck2Message(Ack2Message ack2Message) {
        Buffer buffer = Buffer.buffer();
        JsonObject ack2Json = JsonObject.mapFrom(ack2Message);
        buffer.appendString(GossipMessageFactory.getInstance().makeMessage(MessageType.ACK2_MESSAGE, ack2Json.encode(), getCluster(), getSelf().ipAndPort()).encode());
        return buffer;
    }

    private Buffer encodeShutdownMessage() {
        Buffer buffer = Buffer.buffer();
        JsonObject self = JsonObject.mapFrom(getSelf());
        buffer.appendString(GossipMessageFactory.getInstance().makeMessage(MessageType.SHUTDOWN, self.encode(), getCluster(), getSelf().ipAndPort()).encode());
        return buffer;
    }

    public void apply2LocalState(Map!(GossipMember, HeartbeatState) endpointMembers) {
        GossipMember[] keys;
        foreach(GossipMember k, HeartbeatState v; endpointMembers)
        {
            keys ~= k;
        }
        // Set!(GossipMember) keys = endpointMembers.keySet();
        foreach(GossipMember m ; keys) {
            if (getSelf().opEquals(m)) {
                continue;
            }

            try {
                HeartbeatState localState = getEndpointMembers().get(m);
                HeartbeatState remoteState = endpointMembers.get(m);

                if (localState !is null) {
                    long localHeartbeatTime = localState.getHeartbeatTime();
                    long remoteHeartbeatTime = remoteState.getHeartbeatTime();
                    if (remoteHeartbeatTime > localHeartbeatTime) {
                        remoteStateReplaceLocalState(m, remoteState);
                    } else if (remoteHeartbeatTime == localHeartbeatTime) {
                        long localVersion = localState.getVersion();
                        long remoteVersion = remoteState.getVersion();
                        if (remoteVersion > localVersion) {
                            remoteStateReplaceLocalState(m, remoteState);
                        }
                    }
                } else {
                    remoteStateReplaceLocalState(m, remoteState);
                }
            } catch (Exception e) {
                logError(e.msg);
            }
        }
    }

    private void remoteStateReplaceLocalState(GossipMember member, HeartbeatState remoteState) {
        if (member.getState() == GossipState.UP) {
            up(member);
        }
        if (member.getState() == GossipState.DOWN) {
            down(member);
        }
        if (endpointMembers.containsKey(member)) {
            endpointMembers.remove(member);
        }
        endpointMembers.put(member, remoteState);
    }

    public GossipMember createByDigest(GossipDigest digest) {
        GossipMember member = new GossipMember();
        member.setPort(new Integer(digest.getEndpoint().getPort()));
        member.setIpAddress(digest.getEndpoint().getIp());
        member.setCluster(cluster);
        GossipMember[] keys;
        auto em = getEndpointMembers();
        foreach(GossipMember k, HeartbeatState v; em)
        {
            keys ~= k;
        }
        // Set!(GossipMember) keys = getEndpointMembers().keySet();
        foreach(GossipMember m ; keys) {
            if (m.opEquals(member)) {
                member.setId(m.getId());
                member.setState(m.getState());
                break;
            }
        }

        return member;
    }

    /**
     * send sync message to a live member
     *
     * @param buffer sync data
     * @return if send to a seed member then return TURE
     */
    private bool gossip2LiveMember(Buffer buffer) {
        int liveSize = liveMembers.size();
        if (liveSize <= 0) {
            return false;
        }
        int index = (liveSize == 1) ? 0 : uniform(0,liveSize);
        return sendGossip(buffer, liveMembers, index);
    }

    /**
     * send sync message to a dead member
     *
     * @param buffer sync data
     */
    private void gossip2UndiscoverableMember(Buffer buffer) {
        int deadSize = deadMembers.size();
        if (deadSize <= 0) {
            return;
        }
        int index = (deadSize == 1) ? 0 : uniform(0,deadSize);
        sendGossip(buffer, deadMembers, index);
    }

    private void gossip2Seed(Buffer buffer) {
        int size = settings.getSeedMembers().size();
        if (size > 0) {
            if (size == 1 && settings.getSeedMembers().contains(gossipMember2SeedMember(getSelf()))) {
                return;
            }
            int index = (size == 1) ? 0 : uniform(0,size);
            if (liveMembers.size() == 1) {
                sendGossip2Seed(buffer, settings.getSeedMembers(), index);
            } else {
                double prob = size / /* Double.valueOf */(liveMembers.size())*1.0;
                if (uniform(0.0f, 1.0f) < prob) {
                    sendGossip2Seed(buffer, settings.getSeedMembers(), index);
                }
            }
        }
    }

    private bool sendGossip(Buffer buffer, List!(GossipMember) members, int index) {
        if (buffer !is null && index >= 0) {
            try {
                GossipMember target = members.get(index);
                if (target.opEquals(getSelf())) {
                    int m_size = members.size();
                    if (m_size == 1) {
                        return false;
                    } else {
                        target = members.get((index + 1) % m_size);
                    }
                }
                settings.getMsgService().sendMsg(target.getIpAddress(), target.getPort(), buffer);
                return settings.getSeedMembers().contains(gossipMember2SeedMember(target));
            } catch (Exception e) {
                logError(e.msg);
            }
        }
        return false;
    }

    private bool sendGossip2Seed(Buffer buffer, List!(SeedMember) members, int index) {
        if (buffer !is null && index >= 0) {
            try {
                SeedMember target = members.get(index);
                int m_size = members.size();
                if (target.opEquals(getSelf())) {
                    if (m_size <= 1) {
                        return false;
                    } else {
                        target = members.get((index + 1) % m_size);
                    }
                }
                settings.getMsgService().sendMsg(target.getIpAddress(), target.getPort(), buffer);
                return true;
            } catch (Exception e) {
                logError(e.msg);
            }
        }
        return false;
    }

    private SeedMember gossipMember2SeedMember(GossipMember member) {
        SeedMember seed = new SeedMember(member.getCluster(), member.getIpAddress(), member.getPort(), member.getId());
        return seed;
    }

    private void checkStatus() {
        try {
            GossipMember local = getSelf();
            Map!(GossipMember, HeartbeatState) endpoints = getEndpointMembers();
            GossipMember[] gms;
            foreach(GossipMember k, HeartbeatState v; endpoints)
            {
                gms ~= k;
            }
            // Set!(GossipMember) epKeys = endpoints.keySet();
            foreach(GossipMember k ; gms) {
                if (!k.opEquals(local)) {
                    HeartbeatState state = endpoints.get(k);
                    long now = DateTimeHelper.currentTimeMillis();
                    long duration = now - state.getHeartbeatTime();
                    long convictedTime = convictedTime();
                    logInfo("check : " ~ k.toString() ~ " state : " ~ state.toString() ~ " duration : " ~ duration.to!string ~ " convictedTime : " ~ convictedTime.to!string);
                    if (duration > convictedTime && (isAlive(k) || getLiveMembers().contains(k))) {
                        downing(k, state);
                    }
                    if (duration <= convictedTime && (isDiscoverable(k) || getDeadMembers().contains(k))) {
                        up(k);
                    }
                }
            }
            checkCandidate();
        } catch (Exception e) {
            logError(e.msg);
        }
    }

    private int convergenceCount() {
        int size = getEndpointMembers().size();
        import std.math;
        int count = cast(int) floor(log10(size) + log(size) + 1);
        return count;
    }

    private long convictedTime() {
        return ((convergenceCount() * (settings.getNetworkDelay() * 3 + executeGossipTime)) << 1) + settings.getGossipInterval();
    }

    private bool isDiscoverable(GossipMember member) {
        return member.getState() == GossipState.JOIN || member.getState() == GossipState.DOWN;
    }

    private bool isAlive(GossipMember member) {
        return member.getState() == GossipState.UP;
    }

    public GossipListener getListener() {
        return listener;
    }

    private void fireGossipEvent(GossipMember member, GossipState state) {
        if (getListener() !is null) {
            getListener().gossipEvent(member, state);
        }
    }

//    private void clearMember(GossipMember member) {
//        rwlock.writeLock().lock();
//        try {
//            endpointMembers.remove(member);
//        } finally {
//            rwlock.writeLock().unlock();
//        }
//    }

    public void down(GossipMember member) {
        logInfo("down ~~");
        try {
            rwlock.writer.lock();
            member.setState(GossipState.DOWN);
            liveMembers.remove(member);
            if (!deadMembers.contains(member)) {
                deadMembers.add(member);
            }
//            clearExecutor.schedule(() -> clearMember(member), getSettings().getDeleteThreshold() * getSettings().getGossipInterval(), TimeUnit.MILLISECONDS);
            fireGossipEvent(member, GossipState.DOWN);
        } catch (Exception e) {
            logError(e.msg);
        } finally {
            rwlock.writer.unlock();
        }
    }

    private void up(GossipMember member) {
        try {
            rwlock.writer.lock();
            member.setState(GossipState.UP);
            if (!liveMembers.contains(member)) {
                liveMembers.add(member);
            }
            if (candidateMembers.containsKey(member)) {
                candidateMembers.remove(member);
            }
            if (deadMembers.contains(member)) {
                deadMembers.remove(member);
                logInfo("up ~~");
                 if (!member.opEquals(getSelf())) {
                    fireGossipEvent(member, GossipState.UP);
                }
            }
           
        } catch (Exception e) {
            logError(e.msg);
        } finally {
            rwlock.writer.unlock();
        }

    }

    private void downing(GossipMember member, HeartbeatState state) {
        logInfo("downing ~~");
        try {
            if (candidateMembers.containsKey(member)) {
                CandidateMemberState cState = candidateMembers.get(member);
                if (state.getHeartbeatTime() == cState.getHeartbeatTime()) {
                    cState.updateCount();
                } else if (state.getHeartbeatTime() > cState.getHeartbeatTime()) {
                    candidateMembers.remove(member);
                }
            } else {
                candidateMembers.put(member, new CandidateMemberState(state.getHeartbeatTime()));
            }
        } catch (Exception e) {
            logError(e.msg);
        }
    }

    private void checkCandidate() {
        GossipMember[] keys;
        foreach(GossipMember k, CandidateMemberState v; candidateMembers)
        {
            keys ~= k;
        }
        // Set!(GossipMember) keys = candidateMembers.keySet();
        foreach(GossipMember m ; keys) {
            if (candidateMembers.get(m).getDowningCount() >= convergenceCount()) {
                down(m);
                candidateMembers.remove(m);
            }
        }
    }


    public void shutdown() {
        getSettings().getMsgService().unListen();
        doGossipExecutor.shutdown();
        try {
            import core.thread;
            Thread.sleep(dur!("msecs")(getSettings().getGossipInterval()));
        } catch (InterruptedException e) {
            throw new RuntimeException(e);
        }
        Buffer buffer = encodeShutdownMessage();
        for (int i = 0; i < getLiveMembers().size(); i++) {
            sendGossip(buffer, getLiveMembers(), i);
        }
        _isWorking = false;
    }

}
