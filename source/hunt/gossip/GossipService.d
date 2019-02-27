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

module hunt.gossip.GossipService;

import hunt.text.StringUtils;
import hunt.logging;
import hunt.gossip.event.GossipListener;
import hunt.gossip.model.SeedMember;

import hunt.collection.List;
import hunt.gossip.Common;
import hunt.Integer;
import hunt.gossip.GossipSettings;
import hunt.gossip.GossipManager;
import std.conv;
import hunt.Exceptions;

public class GossipService {
    // private static final Logger LOGGER = LoggerFactory.getLogger(GossipService.class);

    public this(string cluster, string ipAddress, Integer port, string id, List!(SeedMember) seedMembers, GossipSettings settings, GossipListener listener) /* throws Exception */ {
        checkParams(cluster, ipAddress, port, seedMembers);
        if (isNullOrEmpty(id)) {
            id = ipAddress ~ (":") ~ (to!string(port));
        }
        GossipManager.getInstance().init(cluster, ipAddress, port, id, seedMembers, settings, listener);
    }

    public GossipManager getGossipManager() {
        return GossipManager.getInstance();
    }

    public void start() {
        if (getGossipManager().isWorking()) {
            logInfo("Cgossip already workinig");
            return;
        }
        GossipManager.getInstance().start();
    }

    public void shutdown() {
        if (getGossipManager().isWorking()) {
            GossipManager.getInstance().shutdown();
        }
    }

    private void checkParams(string cluster, string ipAddress, Integer port, List!(SeedMember) seedMembers) /* throws Exception */ {
        string f = "[%s] is required!";
        string who = null;
        if (isNullOrEmpty(cluster)) {
            who = "cluster";
        } else if (isNullOrEmpty(ipAddress)) {
            who = "ip";
        } else if (isNullOrEmpty(to!string(port))) {
            who = "port";
        } else if (seedMembers is null || seedMembers.isEmpty()) {
            who = "seed member";
        }
        if (who !is null) {
            throw new IllegalArgumentException(f, who);
        }
    }
}
