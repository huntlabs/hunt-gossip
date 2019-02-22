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

module hunt.gossip.handler.AckMessageHandler;

import hunt.gossip.util.Buffer;
import std.json;
import hunt.gossip.core.GossipManager;
import hunt.gossip.model.Ack2Message;
import hunt.gossip.model.AckMessage;
import hunt.gossip.model.GossipDigest;
import hunt.gossip.model.GossipMember;
import hunt.gossip.model.HeartbeatState;
import hunt.gossip.handler.MessageHandler;
import hunt.collection.HashMap;
import hunt.collection.List;
import hunt.collection.Map;
import hunt.gossip.util.JsonObject;

public class AckMessageHandler : MessageHandler {
    override
    public void handle(string cluster, string data, string from) {
        JsonObject dj = new JsonObject(data);
        AckMessage ackMessage = dj.mapTo!(AckMessage)();

        List!(GossipDigest) olders = ackMessage.getOlders();
        Map!(GossipMember, HeartbeatState) newers = ackMessage.getNewers();

        //update local state
        if (newers.size() > 0) {
            GossipManager.getInstance().apply2LocalState(newers);
        }

        Map!(GossipMember, HeartbeatState) deltaEndpoints = new HashMap!(GossipMember, HeartbeatState)();
        if (olders != null) {
            foreach(GossipDigest d ; olders) {
                GossipMember member = GossipManager.getInstance().createByDigest(d);
                HeartbeatState hb = GossipManager.getInstance().getEndpointMembers().get(member);
                if (hb != null) {
                    deltaEndpoints.put(member, hb);
                }
            }
        }

        if (!deltaEndpoints.isEmpty()) {
            Ack2Message ack2Message = new Ack2Message(deltaEndpoints);
            Buffer ack2Buffer = GossipManager.getInstance().encodeAck2Message(ack2Message);
            if (from != null) {
                string[] host = from.split(":");
                GossipManager.getInstance().getSettings().getMsgService().sendMsg(host[0], Integer.valueOf(host[1]), ack2Buffer);
            }
        }
    }
}
