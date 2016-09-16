module radium.math.utils;

import radium.utility.error;

public import radium.utility.meta : Iota;
public import radium.utility.error : enforce;

class MathException : RadiumException
{
    @nogc @safe pure nothrow this(string msg, string file = __FILE__,
            size_t line = __LINE__, Throwable next = null)
    {
        super(msg, file, line, next);
    }
}
