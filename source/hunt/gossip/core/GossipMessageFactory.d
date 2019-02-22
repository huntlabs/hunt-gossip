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

module hunt.gossip.core.GossipMessageFactory;

import std.json;
import hunt.gossip.model.MessageType;
import hunt.gossip.util.JsonObject;


public class GossipMessageFactory {
    private static GossipMessageFactory ourInstance ;
    public enum string KEY_MSG_TYPE = "msgtype";
    public enum string KEY_DATA = "data";
    public enum string KEY_CLUSTER = "cluster";
    public enum string KEY_FROM = "from";

    shared static this()
    {
        GossipMessageFactory.ourInstance = new GossipMessageFactory();
    }

    public static GossipMessageFactory getInstance() {
        return ourInstance;
    }

    private this() {
    }

    public JsonObject makeMessage(MessageType type, string data, string cluster, string from) {
        JsonObject bj = new JsonObject();
        bj.put(KEY_MSG_TYPE, type.type());
        bj.put(KEY_CLUSTER, cluster);
        bj.put(KEY_DATA, data);
        bj.put(KEY_FROM, from);
        return bj;
    }
}
