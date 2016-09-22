module rdm.graphics.errors;

class GLException : Exception
{
    @nogc @safe pure nothrow this(string msg, string file = __FILE__,
            size_t line = __LINE__, Throwable next = null)
    {
        super(msg, file, line, next);
    }
}

class SDLException : Exception
{
    this(string msg, string file = __FILE__,
            size_t line = __LINE__, Throwable next = null)
    {
        super("An SDL Error Occured:" ~ msg, file, line, next);
    }
}