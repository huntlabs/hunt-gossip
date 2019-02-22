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

module hunt.gossip.model.HeartbeatState;


import hunt.gossip.core.VersionHelper;
import hunt.util.DateTime;
import std.conv;

public class HeartbeatState {
    private long heartbeatTime;
    private long _version;

    public long getHeartbeatTime() {
        return heartbeatTime;
    }

    public void setHeartbeatTime(long heartbeatTime) {
        this.heartbeatTime = heartbeatTime;
    }

    public long getVersion() {
        return _version;
    }

    public void setVersion(long _version) {
        this._version = _version;
    }

    public this() {
        this.heartbeatTime = DateTimeHelper.currentTimeMillis();
        this._version = VersionHelper.getInstance().nextVersion();
    }

    public long updateVersion() {
        setHeartbeatTime(DateTimeHelper.currentTimeMillis());
        this._version = VersionHelper.getInstance().nextVersion();
        return _version;
    }

    override
    public string toString() {
        return "HeartbeatState{" ~
                "heartbeatTime=" ~ heartbeatTime.to!string ~
                ", _version=" ~ _version.to!string ~
                '}';
    }
}
