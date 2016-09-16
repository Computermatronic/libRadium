module radium.streams.stream;

import radium.streams.utils;

enum SeekMode : int
{
    begining = 0,
    offset = 1,
}

interface Stream
{
    size_t read(void[] buffer);
    size_t write(void[] buffer);

    void seek(long amount, SeekMode mode);
    void flush();
    void close();

    @property ulong offset();
    @property bool hasEnded();
    @property bool isOpen();
    @property bool isBidirectional();
}

void[] bufferedRead(Stream stream, size_t amount)
{
    import std.experimental.allocator;

    void[] buffer = theAllocator.allocate(amount);
    size_t amountRead;
    while (amountRead < amount)
    {
        enforce!StreamException(stream.isOpen() && !stream.hasEnded(),
                "Stream ended while reading to buffer!");
        amountRead += stream.read(buffer[amountRead .. $]);
    }
    return buffer;
}

void bufferedWrite(Stream stream, void[] buffer)
{
    size_t amountWritten;
    while (amountWritten < buffer.length)
    {
        enforce!StreamException(stream.isOpen(), "Stream closed while writting from buffer!");
        amountWritten += stream.write(buffer[amountWritten .. $]);
    }
}

T readAs(T)(Stream stream)
{
    auto buffer = stream.bufferedRead(T.sizeof);
    return *(cast(T*) buffer.ptr);
}

T[] readAs(T)(Stream stream, size_t amount)
{
    auto buffer = stream.bufferedRead(T.sizeof * amount);
    return (cast(T*) buffer.ptr)[0 .. amount];
}

void writeAs(T)(Stream stream, T value)
{
    import std.traits : isArray;
    import radium.utility.meta : ArrayElementType;

    void[] buffer;
    static if (isArray!T)
        buffer = (cast(void*) value.ptr)[0 .. value.length * (ArrayElementType!T).sizeof];
    else
        buffer = (cast(void*)&value)[0 .. T.sizeof];
    stream.bufferedWrite(buffer);
}

void[] readAll(Stream stream)
{
    import std.experimental.allocator;
    
	void[] data = theAllocator.allocate(1024);
	ulong totalAmountRead;
	while(!stream.hasEnded())
	{
		if (totalAmountRead >= data.length)
			theAllocator.reallocate(data,data.length + 1024);
		ulong amountRead = stream.read(data[cast(size_t)totalAmountRead..$]);
	}
	return data;
}

void writeTo(Stream reader, Stream writer)
{
    import std.experimental.allocator;

    void[] buffer = theAllocator.allocate(1024);

    while (!reader.hasEnded() && !writer.hasEnded())
    {
        size_t amountRead = reader.read(buffer);
        size_t amountWritten;
        while (amountWritten < amountRead)
        {
            writer.write(buffer[amountWritten .. amountRead]);
        }
    }
}

void writeTo(Stream reader, Stream writer, ulong amount)
{
    import std.experimental.allocator;

    void[] buffer = theAllocator.allocate(1024);
    size_t amountDone;
    while (!reader.hasEnded() && !writer.hasEnded() && amountDone < amount)
    {
        size_t amountRead = reader.read(buffer[0 .. cast(size_t)(amount - amountDone > buffer.length
                ? $ : amount - amountDone)]);
        size_t amountWritten;
        while (amountWritten < amountRead)
        {
            writer.write(buffer[amountWritten .. amountRead]);
        }
        amountDone += amountWritten;
    }
}
