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

module hunt.gossip.model.MessageType;


public struct MessageType {
    enum MessageType SYNC_MESSAGE = MessageType("sync_message");
    enum MessageType ACK_MESSAGE = MessageType("ack_message");
    enum MessageType ACK2_MESSAGE = MessageType("ack2_message");
    enum MessageType SHUTDOWN = MessageType("shutdown");

    private  string _type;

    this(string t) {
        this._type = t;
    }

    public string type()
    {
        return _type;
    }
}
