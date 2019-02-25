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

// import com.fasterxml.jackson.databind.annotation.JsonDeserialize;
// import com.fasterxml.jackson.databind.annotation.JsonSerialize;
import hunt.gossip.core.CustomDeserializer;
import hunt.gossip.core.CustomSerializer;

import hunt.io.Common;
import hunt.collection.List;
import hunt.collection.ArrayList;
import hunt.collection.Map;
import hunt.collection.HashMap;
import hunt.gossip.model.GossipDigest;
import hunt.gossip.model.GossipMember;
import hunt.gossip.model.HeartbeatState;
import std.json;


public class AckMessage : Serializable {
    private List!(GossipDigest) olders;

    // @JsonSerialize(keyUsing = CustomSerializer.class)
    // @JsonDeserialize(keyUsing = CustomDeserializer.class)
    private Map!(GossipMember, HeartbeatState) newers;

    public this() {
    }

    public this(List!(GossipDigest) olders, Map!(GossipMember, HeartbeatState) newers) {
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
                "olders=" ~ olders.toString ~
                ", newers=" ~ newers.toString ~
                '}';
    }

    public JSONValue encode()
    {
        JSONValue data;
        JSONValue[] olders;
        foreach(old; this.olders) {
            olders ~= old.encode();
        }
        JSONValue newers;
        foreach(GossipMember k, HeartbeatState v; this.newers) {
            newers[k.encode.toString] = v.encode();
        }
        data["olders"] = JSONValue(olders);
        data["newers"] = newers;
        return data;
    }

    public static AckMessage decode(JSONValue data)
    {
        try
        {
            List!(GossipDigest) olders = new ArrayList!(GossipDigest)();
            foreach(value; data["olders"].array) {
                olders.add(GossipDigest.decode(value));
            }
            
            Map!(GossipMember, HeartbeatState) newers = new HashMap!(GossipMember, HeartbeatState)();
            foreach(string k, JSONValue v; data["newers"]) {
                newers.put(GossipMember.decode(parseJSON(k)),HeartbeatState.decode(v));
            }
            AckMessage ackm = new AckMessage(olders,newers);
            return ackm;
        }catch(Exception e)
        {}
        return null;
    }

}
