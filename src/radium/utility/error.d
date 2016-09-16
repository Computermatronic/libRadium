module radium.utility.error;

import std.traits;

auto enforce(E, T, string file = __FILE__, size_t line = __LINE__)(T cond, string msg)
{
    static if (isNumeric!T)
    {
        if (cond != 0)
            throw new E(msg, file, line);
    }
    else
    {
        if (!cond)
            throw new E(msg, file, line);
    }
    return cond;
}

class RadiumException : Exception
{
    @nogc @safe pure nothrow this(string msg, string file = __FILE__,
            size_t line = __LINE__, Throwable next = null)
    {
        super(msg, file, line, next);
    }
}
