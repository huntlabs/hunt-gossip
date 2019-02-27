module hunt.gossip.JsonObject;

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
        return toObject!T(_value);
    }

    public static JsonObject mapFrom(T)(T obj)
    {
        return new JsonObject(/* toJSON */(obj.encode()));
    }

    public string encode()
    {
        return _value.toString;
    }

    public JsonObject put(string k , string v)
    {
        _value[k] = v;
        return this;
    }

    public string getString(string k)
    {
        if(k in _value)
        {
            return _value[k].str;
        }
        return string.init;
    }
}