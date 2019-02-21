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

module hunt.gossip.net.udp.UDPMsgService;

import io.netty.util.internal.StringUtil;
import io.vertx.core.Vertx;
import io.vertx.core.buffer.Buffer;
import io.vertx.core.datagram.DatagramSocket;
import io.vertx.core.datagram.DatagramSocketOptions;
import io.vertx.core.json.JsonObject;
import hunt.gossip.core.GossipManager;
import hunt.gossip.core.GossipMessageFactory;
import hunt.gossip.handler.Ack2MessageHandler;
import hunt.gossip.handler.AckMessageHandler;
import hunt.gossip.handler.MessageHandler;
import hunt.gossip.handler.ShutdownMessageHandler;
import hunt.gossip.handler.SyncMessageHandler;
import hunt.gossip.model.MessageType;
import hunt.gossip.net.MsgService;


public class UDPMsgService : MsgService {
    DatagramSocket socket;

    override
    public void listen(string ipAddress, int port) {
        socket = Vertx.vertx().createDatagramSocket(new DatagramSocketOptions());
        socket.listen(port, ipAddress, asyncResult -> {
            if (asyncResult.succeeded()) {
                socket.handler(packet -> handleMsg(packet.data()));
            } else {
                LOGGER.error("Listen failed " ~ asyncResult.cause());
            }
        });
    }

    override
    public void handleMsg(Buffer data) {
        JsonObject j = data.toJsonObject();
        string msgType = j.getString(GossipMessageFactory.KEY_MSG_TYPE);
        string _data = j.getString(GossipMessageFactory.KEY_DATA);
        string cluster = j.getString(GossipMessageFactory.KEY_CLUSTER);
        string from = j.getString(GossipMessageFactory.KEY_FROM);
        if (StringUtil.isNullOrEmpty(cluster) || !GossipManager.getInstance().getCluster().equals(cluster)) {
            LOGGER.error("This message shouldn't exist my world!" ~ data.toString());
            return;
        }
        MessageHandler handler = null;
        MessageType type = MessageType.valueOf(msgType);
        if (type == MessageType.SYNC_MESSAGE) {
            handler = new SyncMessageHandler();
        } else if (type == MessageType.ACK_MESSAGE) {
            handler = new AckMessageHandler();
        } else if (type == MessageType.ACK2_MESSAGE) {
            handler = new Ack2MessageHandler();
        } else if (type == MessageType.SHUTDOWN) {
            handler = new ShutdownMessageHandler();
        } else {
            LOGGER.error("Not supported message type");
        }
        if (handler != null) {
            handler.handle(cluster, _data, from);
        }
    }

    override
    public void sendMsg(string targetIp, Integer targetPort, Buffer data) {
        if (targetIp != null && targetPort != null && data != null) {
            socket.send(data, targetPort, targetIp, asyncResult -> {
            });
        }
    }

    override
    public void unListen() {
        if (socket != null) {
            socket.close(asyncResult -> {
                if (asyncResult.succeeded()) {
                    LOGGER.info("Socket was close!");
                } else {
                    LOGGER.error("Close socket an error has occurred. " ~ asyncResult.cause().getMessage());
                }
            });
        }
    }
}
