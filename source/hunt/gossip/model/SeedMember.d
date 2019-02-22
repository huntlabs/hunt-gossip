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

module hunt.gossip.model.SeedMember;
import hunt.Integer;
import hunt.io.Common;



public class SeedMember : Serializable {
    private string cluster;
    private string ipAddress;
    private Integer port;
    private string id;

    public this(string cluster, string ipAddress, Integer port, string id) {
        this.cluster = cluster;
        this.ipAddress = ipAddress;
        this.port = port;
        this.id = id;
    }

    public this() {

    }

    public string getCluster() {
        return cluster;
    }

    public void setCluster(string cluster) {
        this.cluster = cluster;
    }

    public string getIpAddress() {
        return ipAddress;
    }

    public void setIpAddress(string ipAddress) {
        this.ipAddress = ipAddress;
    }

    public Integer getPort() {
        return port;
    }

    public void setPort(Integer port) {
        this.port = port;
    }

    public string getId() {
        return id;
    }

    public void setId(string id) {
        this.id = id;
    }
    
    public string eigenvalue(){
        return getCluster() ~ (":") ~ (getIpAddress()) ~ (":") ~ (getPort().toString());
    }

    override
    public bool opEquals(Object o) {
        if (this is o) return true;
        if (o is null || typeid(this) != typeid(o)) return false;

        SeedMember that = cast(SeedMember) o;

        if (!(cluster == that.cluster)) return false;
        if (!(ipAddress == that.ipAddress)) return false;
        return port.intValue() == that.port.intValue();
    }

    override
    public size_t toHash() @trusted nothrow {
        int result = cluster.hashOf();
        result = 31 * result + ipAddress.hashOf();
        result = 31 * result + port.hashOf();
        return result;
    }

    override
    public string toString() {
        return "SeedMember{" ~
                "cluster='" ~ cluster ~ '\'' ~
                ", ipAddress='" ~ ipAddress ~ '\'' ~
                ", port=" ~ port.toString ~
                ", id='" ~ id ~ '\'' ~
                '}';
    }
}
