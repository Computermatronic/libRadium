module rdm.stream.core;

interface InputStream
{
    size_t read(void[] buffer);

    @property bool dataPending();
    @property bool open();
    void close();
}

interface OutputStream
{
    size_t write(void[] buffer);

    void flush();

    @property bool open();
    void close();
}

interface SeekableStream
{
    void seek(long offset, SeekMode mode);
    @property ulong offset();

    @property bool open();
    void close();
}

interface IOStream : InputStream, OutputStream
{
}

interface RIStream : InputStream, SeekableStream
{
}

interface ROStream : OutputStream, SeekableStream
{
}

interface RIOStream : IOStream, RIStream, ROStream, SeekableStream
{
}

enum SeekMode : int
{
    begining = 0,
    offset = 1,
}

auto throwAway(T)(T stream) if (is(T : InputStream) || is(T : OutputStream))
{
    struct Result
    {
        T object;
        alias object this;

        this(T object)
        {
            this.object = object;
        }

        ~this()
        {
            this.object.close();
            delete this.object;
        }
    }

    return Result(stream);
}

auto readAs(T)(InputStream stream)
{
    import core.stdc.stdlib : alloca;

    auto buffer = alloca(T.sizeof)[0 .. T.sizeof];
    stream.read(buffer);
    return *(cast(T*) buffer.ptr);
}

auto readAs(T)(InputStream stream, size_t count)
{
    auto buffer = new void[](T.sizeof * count);
    stream.read(buffer);
    return (cast(T*) buffer.ptr)[0 .. count];
}

auto writeAs(T)(OutputStream stream, T data)
{
    import std.traits : isArray;

    static if (isArray!T)
        stream.write((cast(void*) data.ptr)[0 .. data.length * typeof(T.init[0]).sizeof]);
    else
        stream.write((cast(void*)&data)[0 .. T.sizeof]);
}

class StreamException : Exception
{
    @nogc @safe pure nothrow this(string msg, string file = __FILE__,
            size_t line = __LINE__, Throwable next = null)
    {
        super(msg, file, line, next);
    }
}
