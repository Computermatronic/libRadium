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

interface RIStream : InputStream, SeekableStream
{
}

interface ROStream : OutputStream, SeekableStream
{
}

interface IOStream : InputStream, OutputStream
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

enum isInputStream(T) = is(T == InputStream) || is(T : InputStream);
enum isOutputStream(T) = is(T == OutputStream) || is(T : OutputStream);
enum isRIStream(T) = is(T == RIStream) || is(T : RIStream);
enum isROStream(T) = is(T == ROStream) || is(T : ROStream);
enum isIOStream(T) = is(T == IOStream) || is(T : IOStream);
enum isRIOStream(T) = is(T == RIOStream) || is(T : RIOStream);

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

void copyTo(InputStream source, OutputStream destination, ulong amount)
{
    import core.stdc.stdlib : alloca;

    ulong total;
    auto buffer = alloca(1024)[0 .. 1024];
    while (total < amount)
    {
        size_t amountRead = source.read(buffer);
        total += amountRead;
        destination.write(buffer[0 .. amountRead]);
    }
}

void copyTo(InputStream source, OutputStream destination)
{
    import core.stdc.stdlib : alloca;

    ulong total;
    auto buffer = alloca(1024)[0 .. 1024];
    while (source.dataPending)
    {
        size_t amountRead = source.read(buffer);
        destination.write(buffer[0 .. amountRead]);
    }
}

class StreamException : Exception
{
    @nogc @safe pure nothrow this(string msg, string file = __FILE__,
            size_t line = __LINE__, Throwable next = null)
    {
        super(msg, file, line, next);
    }
}
