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

module hunt.gossip.core.Serializer;

import hunt.gossip.util.Buffer;
import std.json;
import hunt.logging;
import hunt.io.Common;
import hunt.gossip.util.JsonObject;


public class Serializer {
    private static Serializer ourInstance ;
    public static Serializer getInstance() {
        if(ourInstance is null)
        {
            ourInstance = new Serializer();
        }
        return ourInstance;
    }

    private this() {
    }

    public static Buffer encode(T)(Serializable obj) {
        Buffer buffer = Buffer.buffer();
        try {
            buffer.appendString(JsonObject.mapFrom(cast(T)obj).encode());
        } catch (Exception e) {
            logError(e.msg);
        }
        return buffer;
    }

    public T decode(T)(Buffer buffer) {
        T gdsm = null;
        if (buffer !is null) {
            try {
                gdsm = buffer.toJsonObject().mapTo!(T)();
            } catch (Exception e) {
                logError(e.msg);
            }
        }
        return gdsm;
    }
}
