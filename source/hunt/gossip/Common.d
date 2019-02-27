module hunt.gossip.Common;

bool isNullOrEmpty(string str)
{
    return (str is null) || (str.length == 0);
}

class InetSocketAddress
{
    private{   
        string _ip;
        int _port;
    }

    this(string ip ,int port)
    {
        _ip = ip;
        _port = port;
    }

    string getIp()
    {
        return _ip;
    }

    int getPort()
    {
        return _port;
    }

}