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

module hunt.gossip.handler.ShutdownMessageHandler;

import std.json;
import hunt.gossip.GossipManager;
import hunt.gossip.model.GossipMember;
import hunt.gossip.JsonObject;
import hunt.gossip.handler.MessageHandler;


public class ShutdownMessageHandler : MessageHandler {
    override
    public void handle(string cluster, string data, string from) {
        // JsonObject dj = new JsonObject(data);
        GossipMember whoShutdown = GossipMember.decode(parseJSON(data))/* dj.mapTo!(GossipMember)() */;
        if (whoShutdown !is null) {
            GossipManager.getInstance().down(whoShutdown);
        }
    }
}
