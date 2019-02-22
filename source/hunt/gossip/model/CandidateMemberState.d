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

module hunt.gossip.model.CandidateMemberState;

// import hunt.concurrency.atomic.AtomicInteger;

import core.atomic;

public class CandidateMemberState {
    private long heartbeatTime;
    private int downingCount;

    public this(long heartbeatTime) {
        this.heartbeatTime = heartbeatTime;
         atomicStore(this.downingCount,0);
    }

    public void updateCount() {
        // this.downingCount.incrementAndGet();
        atomicOp!"+="(this.downingCount,1);
    }

    public long getHeartbeatTime() {
        return heartbeatTime;
    }

    public void setHeartbeatTime(long heartbeatTime) {
        this.heartbeatTime = heartbeatTime;
    }

    public int getDowningCount() {
        return automicLoad(downingCount);
    }

    public void setDowningCount(int downingCount) {
        // this.downingCount = downingCount;
         atomicStore(this.downingCount,downingCount);

    }

    override
    public string toString() {
        return "CandidateMemberState{" ~
                "heartbeatTime=" ~ heartbeatTime ~
                ", downingCount=" ~ downingCount.get() ~
                '}';
    }
}
