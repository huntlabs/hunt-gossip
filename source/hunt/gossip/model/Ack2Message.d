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

module hunt.gossip.model.Ack2Message;

import hunt.io.Common;
import hunt.collection.Map;
import hunt.collection.HashMap;
import hunt.gossip.model.GossipMember;
import hunt.gossip.model.HeartbeatState;
import std.json;

public class Ack2Message : Serializable {

    private Map!(GossipMember, HeartbeatState) endpoints;

    public this() {
    }

    public this(Map!(GossipMember, HeartbeatState) endpoints) {

        this.endpoints = endpoints;
    }

    override
    public string toString() {
        return "GossipDigestAck2Message{" ~
                "endpoints=" ~ endpoints.toString ~
                '}';
    }

    public Map!(GossipMember, HeartbeatState) getEndpoints() {
        return endpoints;
    }

    public void setEndpoints(Map!(GossipMember, HeartbeatState) endpoints) {
        this.endpoints = endpoints;
    }

    public JSONValue encode()
    {
        JSONValue data;
        foreach(GossipMember k, HeartbeatState v; endpoints) {
            data[k.encode.toString] = v.encode();
        }
        return data;
    }

    public static Ack2Message decode(JSONValue data)
    {
        try
        {
            Map!(GossipMember, HeartbeatState) es = new HashMap!(GossipMember, HeartbeatState)();
            foreach(string k, JSONValue v; data) {
                es.put(GossipMember.decode(parseJSON(k)),HeartbeatState.decode(v));
            }
            Ack2Message ack2m = new Ack2Message(es);
            return ack2m;
        }catch(Exception e)
        {}
        return null;
    }
}
