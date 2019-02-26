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

module hunt.gossip.net.MsgService;

import hunt.gossip.util.Buffer;
import hunt.logging;
import hunt.Integer;

public interface MsgService {
    // Logger LOGGER = LoggerFactory.getLogger(MsgService.class);

    void listen(string ipAddress, int port);

    void handleMsg(Buffer data);

    void sendMsg(string targetIp, Integer targetPort, Buffer data);

    void unListen();

    void start();

    void stop();
}
