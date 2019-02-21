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

module hunt.gossip.model.AckMessage;

import com.fasterxml.jackson.databind.annotation.JsonDeserialize;
import com.fasterxml.jackson.databind.annotation.JsonSerialize;
import hunt.gossip.core.CustomDeserializer;
import hunt.gossip.core.CustomSerializer;

import java.io.Serializable;
import hunt.collection.List;
import hunt.collection.Map;


public class AckMessage : Serializable {
    private List!(GossipDigest) olders;

    @JsonSerialize(keyUsing = CustomSerializer.class)
    @JsonDeserialize(keyUsing = CustomDeserializer.class)
    private Map!(GossipMember, HeartbeatState) newers;

    public AckMessage() {
    }

    public AckMessage(List!(GossipDigest) olders, Map!(GossipMember, HeartbeatState) newers) {
        this.olders = olders;
        this.newers = newers;
    }

    public List!(GossipDigest) getOlders() {
        return olders;
    }

    public void setOlders(List!(GossipDigest) olders) {
        this.olders = olders;
    }

    public Map!(GossipMember, HeartbeatState) getNewers() {
        return newers;
    }

    public void setNewers(Map!(GossipMember, HeartbeatState) newers) {
        this.newers = newers;
    }

    override
    public string toString() {
        return "AckMessage{" ~
                "olders=" ~ olders ~
                ", newers=" ~ newers +
                '}';
    }

}
