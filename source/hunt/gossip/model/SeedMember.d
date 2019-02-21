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

import java.io.Serializable;


public class SeedMember : Serializable {
    private string cluster;
    private string ipAddress;
    private Integer port;
    private string id;

    public SeedMember(string cluster, string ipAddress, Integer port, string id) {
        this.cluster = cluster;
        this.ipAddress = ipAddress;
        this.port = port;
        this.id = id;
    }

    public SeedMember() {

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
        return getCluster().concat(":").concat(getIpAddress()).concat(":").concat(getPort().toString());
    }

    override
    public boolean equals(Object o) {
        if (this == o) return true;
        if (o == null || getClass() != o.getClass()) return false;

        SeedMember that = (SeedMember) o;

        if (!cluster.equals(that.cluster)) return false;
        if (!ipAddress.equals(that.ipAddress)) return false;
        return port.equals(that.port);
    }

    override
    public int hashCode() {
        int result = cluster.hashCode();
        result = 31 * result + ipAddress.hashCode();
        result = 31 * result + port.hashCode();
        return result;
    }

    override
    public string toString() {
        return "SeedMember{" ~
                "cluster='" ~ cluster + '\'' ~
                ", ipAddress='" ~ ipAddress + '\'' ~
                ", port=" ~ port ~
                ", id='" ~ id + '\'' +
                '}';
    }
}