// Copyright (C) 2018-2019 HuntLabs. All rights reserved.
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

module hunt.gossip.handler.SyncMessageHandler;

import hunt.gossip.Buffer;
import hunt.gossip.GossipManager;
import hunt.gossip.Serializer;
import hunt.gossip.model.AckMessage;
import hunt.gossip.model.GossipDigest;
import hunt.gossip.model.GossipMember;
import hunt.gossip.model.HeartbeatState;
import hunt.gossip.handler.MessageHandler;
import hunt.collection.ArrayList;
import hunt.collection.HashMap;
import hunt.collection.List;
import hunt.collection.Map;
import hunt.collection.Set;
import std.json;
import hunt.Integer;
import std.array;
import hunt.logging;

public class SyncMessageHandler : MessageHandler {
    override
    public void handle(string cluster, string data, string from) {
        if (data !is null) {
            try {
                JSONValue array = parseJSON(data);
                List!(GossipDigest) olders = new ArrayList!(GossipDigest)();
                Map!(GossipMember, HeartbeatState) newers = new HashMap!(GossipMember, HeartbeatState)();
                List!(GossipMember) gMemberList = new ArrayList!(GossipMember)();
                foreach(JSONValue e ; array.array) {
                    GossipDigest g = GossipDigest.decode(e)/* Serializer.getInstance().decode!(GossipDigest)(Buffer.buffer().appendString(e.toString())) */;
                    if(g is null)
                        logError("GossipDigest decode error : ",e);
                    GossipMember member = new GossipMember();
                    member.setCluster(cluster);
                    member.setIpAddress(g.getEndpoint().getIp());
                    member.setPort(new Integer(g.getEndpoint().getPort()));
                    member.setId(g.getId());
                    gMemberList.add(member);

                    compareDigest(g, member, cluster, olders, newers);
                }
                // I have, you don't have
                Map!(GossipMember, HeartbeatState) endpoints = GossipManager.getInstance().getEndpointMembers();
                GossipMember[] epKeys;
                foreach(GossipMember k, HeartbeatState v; endpoints) {
                    epKeys ~= k;
                }
                // Set!(GossipMember) epKeys = endpoints.keySet();
                foreach(GossipMember m ; epKeys) {
                    if (!gMemberList.contains(m)) {
                        newers.put(m, endpoints.get(m));
                    }
                    if (m.opEquals(GossipManager.getInstance().getSelf())) {
                        newers.put(m, endpoints.get(m));
                    }
                }
                AckMessage ackMessage = new AckMessage(olders, newers);
                Buffer ackBuffer = GossipManager.getInstance().encodeAckMessage(ackMessage);
                if (from !is null) {
                    string[] host = from.split(":");
                    GossipManager.getInstance().getSettings().getMsgService().sendMsg(host[0], Integer.valueOf(host[1]), ackBuffer);
                }
            } catch (Throwable e) {
                logError(e.msg);
            }
        }
    }

    private void compareDigest(GossipDigest g, GossipMember member, string cluster, List!(GossipDigest) olders, Map!(GossipMember, HeartbeatState) newers) {

        try {
            HeartbeatState hb = GossipManager.getInstance().getEndpointMembers().get(member);
            long remoteHeartbeatTime = g.getHeartbeatTime();
            long remoteVersion = g.getVersion();
            if (hb !is null) {
                long localHeartbeatTime = hb.getHeartbeatTime();
                long localVersion = hb.getVersion();

                if (remoteHeartbeatTime > localHeartbeatTime) {
                    olders.add(g);
                } else if (remoteHeartbeatTime < localHeartbeatTime) {
                    newers.put(member, hb);
                } else if (remoteHeartbeatTime == localHeartbeatTime) {
                    if (remoteVersion > localVersion) {
                        olders.add(g);
                    } else if (remoteVersion < localVersion) {
                        newers.put(member, hb);
                    }
                }
            } else {
                olders.add(g);
            }
        } catch (Exception e) {
            logError(e.msg);
        }
    }
}
