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

module hunt.gossip.model.GossipMember;

import hunt.io.Common;
import hunt.Integer;
import hunt.gossip.model.GossipState;
import std.conv;
import std.json;

public class GossipMember : Serializable {
    private string cluster;
    private string ipAddress;
    private Integer port;
    private string id;
    private GossipState state;

    public this() {
    }

    public this(string cluster, string ipAddress, Integer port, string id, GossipState state) {
        this.cluster = cluster;
        this.ipAddress = ipAddress;
        this.port = port;
        this.id = id;
        this.state = state;
    }

    public GossipState getState() {
        return state;
    }

    public void setState(GossipState state) {
        this.state = state;
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
        if (id is null) {
            setId(ipAndPort());
        }
        return id;
    }

    public void setId(string id) {
        this.id = id;
    }

    override
    public string toString() {
        return "GossipMember{" ~
                "cluster='" ~ cluster ~ '\'' ~
                ", ipAddress='" ~ ipAddress ~ '\'' ~
                ", port=" ~ port.to!string ~
                ", id='" ~ id ~ '\'' ~
                ", state=" ~ state.state() ~
                '}';
    }

    override
    public bool opEquals(Object o) {
        if (this is o) return true;
        if (o is null || typeid(this) != typeid(o)) return false;

        GossipMember member = cast(GossipMember) o;

        if (!(cluster == member.cluster)) return false;
        if (!(ipAddress == member.ipAddress)) return false;
        return port.intValue() == member.port.intValue();
    }

    override
    public  size_t toHash() @trusted nothrow {
        size_t result = cluster.hashOf();
        result = 31 * result + ipAddress.hashOf();
        result = 31 * result + port.hashOf();
        return result;
    }

    public string ipAndPort() {
        return ipAddress ~ (":") ~ (to!string(port));
    }
    
    public string eigenvalue(){
        return getCluster() ~ (":") ~ (getIpAddress()) ~ (":") ~ (getPort().toString());
    }

    public JSONValue encode()
    {
        JSONValue data;
        data["cluster"] = cluster;
        data["ipAddress"] = ipAddress;
        data["port"] = port.intValue();
        data["id"] = id;
        data["state"] = state.state();
        return data;
    }

    public static GossipMember decode(JSONValue data)
    {
        try
        {
            GossipMember gm = new GossipMember(data["cluster"].str,data["ipAddress"].str,new Integer(cast(int)(data["port"].integer)),data["id"].str,GossipState(data["state"].str));
            return gm;
        }catch(Exception e)
        {}
        return null;
    }
}
