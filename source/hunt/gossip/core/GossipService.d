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

module hunt.gossip.core.GossipService;

import io.netty.util.internal.StringUtil;
import io.vertx.core.logging.Logger;
import io.vertx.core.logging.LoggerFactory;
import hunt.gossip.event.GossipListener;
import hunt.gossip.model.SeedMember;

import hunt.collection.List;


public class GossipService {
    private static final Logger LOGGER = LoggerFactory.getLogger(GossipService.class);

    public GossipService(string cluster, string ipAddress, Integer port, string id, List!(SeedMember) seedMembers, GossipSettings settings, GossipListener listener) throws Exception {
        checkParams(cluster, ipAddress, port, seedMembers);
        if (StringUtil.isNullOrEmpty(id)) {
            id = ipAddress.concat(":").concat(string.valueOf(port));
        }
        GossipManager.getInstance().init(cluster, ipAddress, port, id, seedMembers, settings, listener);
    }

    public GossipManager getGossipManager() {
        return GossipManager.getInstance();
    }

    public void start() {
        if (getGossipManager().isWorking()) {
            LOGGER.info("Cgossip already workinig");
            return;
        }
        GossipManager.getInstance().start();
    }

    public void shutdown() {
        if (getGossipManager().isWorking()) {
            GossipManager.getInstance().shutdown();
        }
    }

    private void checkParams(string cluster, string ipAddress, Integer port, List!(SeedMember) seedMembers) throws Exception {
        string f = "[%s] is required!";
        string who = null;
        if (StringUtil.isNullOrEmpty(cluster)) {
            who = "cluster";
        } else if (StringUtil.isNullOrEmpty(ipAddress)) {
            who = "ip";
        } else if (StringUtil.isNullOrEmpty(string.valueOf(port))) {
            who = "port";
        } else if (seedMembers == null || seedMembers.isEmpty()) {
            who = "seed member";
        }
        if (who != null) {
            throw new IllegalArgumentException(string.format(f, who));
        }
    }
}