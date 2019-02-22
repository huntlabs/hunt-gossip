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

import hunt.text.StringUtils;

// import io.vertx.core.Vertx;
import hunt.gossip.util.Buffer;

// import io.vertx.core.datagram.DatagramSocket;
// import io.vertx.core.datagram.DatagramSocketOptions;
import std.json;
import hunt.gossip.core.GossipManager;
import hunt.gossip.core.GossipMessageFactory;
import hunt.gossip.handler.Ack2MessageHandler;
import hunt.gossip.handler.AckMessageHandler;
import hunt.gossip.handler.MessageHandler;
import hunt.gossip.handler.ShutdownMessageHandler;
import hunt.gossip.handler.SyncMessageHandler;
import hunt.gossip.model.MessageType;
import hunt.gossip.net.MsgService;
import hunt.gossip.util.JsonObject;
import hunt.gossip.util.Common;
import hunt.Integer;
import hunt.logging;
import hunt.event;
import hunt.io.UdpSocket : UdpSocket;
import std.socket;
import std.functional;
import std.exception;
import core.thread;
import core.time;
import std.stdio;

public class UDPMsgService : MsgService
{
    // DatagramSocket socket;
    EventLoop _loop;
    UdpSocket _udpSocket;

    this()
    {
        _loop = new EventLoop();
        _udpSocket = new UdpSocket(_loop);
    }

    override public void listen(string ipAddress, int port)
    {
        // socket = Vertx.vertx().createDatagramSocket(new DatagramSocketOptions());
        // socket.listen(port, ipAddress, asyncResult -> {
        //     if (asyncResult.succeeded()) {
        //         socket.handler(packet -> handleMsg(packet.data()));
        //     } else {
        //         logError("Listen failed " ~ asyncResult.cause());
        //     }
        // });

        _udpSocket.bind(ipAddress, cast(ushort)port).setReadData((in ubyte[] data, Address addr) {
            debug writefln("Server => client: %s, received: %s", addr, cast(string) data);
            handleMsg(Buffer.buffer().appendString(cast(string) data));
        }).start();

        _loop.run();
    }

    override public void handleMsg(Buffer data)
    {
        JsonObject j = data.toJsonObject();
        string msgType = j.getString(GossipMessageFactory.KEY_MSG_TYPE);
        string _data = j.getString(GossipMessageFactory.KEY_DATA);
        string cluster = j.getString(GossipMessageFactory.KEY_CLUSTER);
        string from = j.getString(GossipMessageFactory.KEY_FROM);
        if (isNullOrEmpty(cluster) || !(GossipManager.getInstance().getCluster() == cluster))
        {
            logError("This message shouldn't exist my world!" ~ data.toString());
            return;
        }
        MessageHandler handler = null;
        MessageType type = MessageType(msgType);
        if (type.type() == MessageType.SYNC_MESSAGE.type())
        {
            handler = new SyncMessageHandler();
        }
        else if (type.type() == MessageType.ACK_MESSAGE.type())
        {
            handler = new AckMessageHandler();
        }
        else if (type.type() == MessageType.ACK2_MESSAGE.type())
        {
            handler = new Ack2MessageHandler();
        }
        else if (type.type() == MessageType.SHUTDOWN.type())
        {
            handler = new ShutdownMessageHandler();
        }
        else
        {
            logError("Not supported message type");
        }
        if (handler !is null)
        {
            handler.handle(cluster, _data, from);
        }
    }

    override public void sendMsg(string targetIp, Integer targetPort, Buffer data)
    {
        if (targetIp !is null && targetPort !is null && data !is null)
        {
            // socket.send(data, targetPort, targetIp, asyncResult -> {
            // });
            _udpSocket.sendTo(data.data(), new InternetAddress(targetIp,cast(ushort)(targetPort.intValue)));
        }
    }

    override public void unListen()
    {
        if (_udpSocket !is null)
        {
            // socket.close(asyncResult -> {
            //     if (asyncResult.succeeded()) {
            //         logInfo("Socket was close!");
            //     } else {
            //         logError("Close socket an error has occurred. " ~ asyncResult.cause().msg);
            //     }
            // });
            _udpSocket.close();
        }
    }
}
