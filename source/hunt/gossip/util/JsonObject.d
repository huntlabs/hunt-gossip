module hunt.gossip.util.JsonObject;

import hunt.util.Serialize;
import std.json;

class JsonObject
{
    private JSONValue _value;

    this(){}
    
    this(string str)
    {
        _value = parseJSON(str);
    }

    this(JSONValue value)
    {
        _value = value;
    }

    public T mapTo(T)()
    {
        toObject!T(_value);
    }

    public static JsonObject mapFrom(T)(T obj)
    {
        return new JsonObject(toJson(obj));
    }

    public string encode()
    {
        return _value.toString;
    }
}