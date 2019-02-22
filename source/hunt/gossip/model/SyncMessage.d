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

module hunt.gossip.model.SyncMessage;

import hunt.io.Common;
import hunt.collection.List;
import hunt.gossip.model.GossipDigest;


public class SyncMessage : Serializable {
    private string cluster;
    private List!(GossipDigest) digestList;

    public this() {
    }

    public this(string cluster, List!(GossipDigest) digestList) {
        this.cluster = cluster;
        this.digestList = digestList;
    }

    public string getCluster() {
        return cluster;
    }

    public void setCluster(string cluster) {
        this.cluster = cluster;
    }

    public List!(GossipDigest) getDigestList() {
        return digestList;
    }

    public void setDigestList(List!(GossipDigest) digestList) {
        this.digestList = digestList;
    }

    override
    public string toString() {
        return "GossipDigestSyncMessage{" ~
                "cluster='" ~ cluster ~ '\'' ~
                ", digestList=" ~ digestList ~
                '}';
    }

}
