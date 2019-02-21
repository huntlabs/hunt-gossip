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

module hunt.gossip.model.Ack2Message;


import com.fasterxml.jackson.databind.annotation.JsonDeserialize;
import com.fasterxml.jackson.databind.annotation.JsonSerialize;
import hunt.gossip.core.CustomDeserializer;
import hunt.gossip.core.CustomSerializer;

import java.io.Serializable;
import hunt.collection.Map;


public class Ack2Message : Serializable {
    @JsonSerialize(keyUsing = CustomSerializer.class)
    @JsonDeserialize(keyUsing = CustomDeserializer.class)
    private Map!(GossipMember, HeartbeatState) endpoints;

    public Ack2Message() {
    }

    public Ack2Message(Map!(GossipMember, HeartbeatState) endpoints) {

        this.endpoints = endpoints;
    }

    override
    public string toString() {
        return "GossipDigestAck2Message{" ~
                "endpoints=" ~ endpoints +
                '}';
    }

    public Map!(GossipMember, HeartbeatState) getEndpoints() {
        return endpoints;
    }

    public void setEndpoints(Map!(GossipMember, HeartbeatState) endpoints) {
        this.endpoints = endpoints;
    }
}
