module hunt.gossip.Buffer;

import hunt.util.Common;
import std.ascii;
import std.algorithm;
import std.array;
import std.exception;
import std.conv;
import std.string;
import std.uni;
import std.json;
import hunt.gossip.JsonObject;


class Buffer : Appendable {
    private Appender!(byte[]) _buffer;

    private this(size_t capacity = 16) {
        _buffer.reserve(capacity);
    }

    private this(string data, size_t capacity = 16) {
        _buffer.reserve(capacity);
        this.append(data);
    }

    static Buffer buffer()
    {
        return new Buffer();
    }

    void reset() {
        _buffer.clear();
    }

    Buffer setCharAt(int index, char c) {
        _buffer.data[index] = c;
        return this;
    }

    Buffer append(char s) {
        _buffer.put(s);
        return this;
    }

    Buffer append(bool s) {
        append(s.to!string());
        return this;
    }

    Buffer append(int i) {
        _buffer.put(cast(byte[])(to!(string)(i)));
        return this;
    }

    Buffer append(float f) {
        _buffer.put(cast(byte[])(to!(string)(f)));
        return this;
    }

    Buffer append(const(char)[] s) {
        _buffer.put(cast(byte[]) s);
        return this;
    }

    Buffer append(const(char)[] s, int start, int end) {
        _buffer.put(cast(byte[]) s[start .. end]);
        return this;
    }

    /// Warning: It's different from the previous one.
    Buffer append(byte[] str, int offset, int len) {
        _buffer.put(str[offset .. offset + len]);
        return this;
    }

    Buffer append(Object obj) {
        _buffer.put(cast(byte[])(obj.toString));
        return this;
    }

    int length() {
        return cast(int) _buffer.data.length;
    }

    void setLength(int newLength) {
        _buffer.shrinkTo(newLength);
    }

    int lastIndexOf(string s) {
        string source = cast(string) _buffer.data;
        return cast(int) source.lastIndexOf(s);
    }

    char charAt(int idx)
    {
        if(length() > idx)
           return _buffer.data[idx];
        else
            return ' ';
    }

    public Buffer deleteCharAt(int index) {
        if(index < length())
        {
            auto data = _buffer.data.idup;
            for(int i = index+1 ; i < data.length ; i++)
            {
                _buffer.data[i-1] = data[i];
            }
            setLength(cast(int)(data.length-1));
        }
        return this;
    }

    public Buffer insert(int index, char c) {
        if(index <= length())
        {
            auto data = _buffer.data.idup;
            for(int i = index ; i < data.length ; i++)
            {
                _buffer.data[i+1] = data[i];
            }
            _buffer.data[index] = c;
            setLength(cast(int)(data.length+1));
        }
        return this;
    }

    public Buffer insert(int index, long data) {
        auto bytes = cast(byte[])(to!string(data));
        auto start = index;
        foreach( b; bytes) {
            insert(start , cast(char)b);
            start++;
        }
        return this;
    }

    public Buffer replace(int start, int end, string str) {
        if( start <= end && start < length() && end < length())
        {
            if(str.length >= end)
                _buffer.data[start .. end ] = cast(byte[])(str[start .. end]);
        }
        return this;
    }

    override string toString() {
        string s = cast(string) _buffer.data.idup;
        if (s is null)
            return "";
        else
            return s;
    }

    public byte[] data()
    {
        return _buffer.data.dup;
    }

    public JsonObject toJsonObject()
    {
        try{
            return new JsonObject(parseJSON(cast(string)data()));
        }
        catch(Exception e)
        {
        }
        return null;
    }

    public Buffer appendString(string str)
    {
        return append(str);
    }

}
