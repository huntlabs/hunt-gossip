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
module hunt.gossip.GossipSettings;


import hunt.gossip.model.SeedMember;
import hunt.gossip.net.MsgService;
import hunt.gossip.net.udp.UDPMsgService;
import hunt.gossip.GossipManager;

import hunt.collection.ArrayList;
import hunt.collection.List;


public class GossipSettings {
    //Time between gossip ping in ms. Default is 1 second
    private int gossipInterval = 1000;

    //Network delay in ms. Default is 200ms
    private int networkDelay = 200;

    //Which message sync implementation. Default is UDPMsgService.class
    private MsgService msgService;

    //Delete the deadth node when the sync message is not received more than [deleteThreshold] times
    private int deleteThreshold = 3;

    private List!(SeedMember) seedMembers;

    this()
    {
        seedMembers =  new ArrayList!(SeedMember)();
        msgService = new UDPMsgService();
    }

    public int getGossipInterval() {
        return gossipInterval;
    }

    public void setGossipInterval(int gossipInterval) {
        this.gossipInterval = gossipInterval;
    }

    public int getNetworkDelay() {
        return networkDelay;
    }

    public void setNetworkDelay(int networkDelay) {
        this.networkDelay = networkDelay;
    }

    public List!(SeedMember) getSeedMembers() {
        return seedMembers;
    }

     public void setSeedMembers(List!(SeedMember) seedMembers) {
        List!(SeedMember) _seedMembers = new ArrayList!(SeedMember)();
        if(seedMembers !is null && !seedMembers.isEmpty()){
            foreach(SeedMember seed ;seedMembers){
                import hunt.text.Common;

                if(!seed.eigenvalue().equalsIgnoreCase(GossipManager.getInstance().getSelf().eigenvalue())){
                    if(!_seedMembers.contains(seed)){
                        _seedMembers.add(seed);
                    }
                }
            }
        }
        this.seedMembers = seedMembers;
    }

    public MsgService getMsgService() {
        return msgService;
    }

    public void setMsgService(MsgService msgService) {
        this.msgService = msgService;
    }

    public int getDeleteThreshold() {
        return deleteThreshold;
    }

    public void setDeleteThreshold(int deleteThreshold) {
        this.deleteThreshold = deleteThreshold;
    }
}
