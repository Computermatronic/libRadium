module radium.streams.utils;

import radium.utility.error;

public import radium.utility.error : enforce;

class StreamException : RadiumException
{
    @nogc @safe pure nothrow this(string msg, string file = __FILE__,
            size_t line = __LINE__, Throwable next = null)
    {
        super(msg, file, line, next);
    }
}
