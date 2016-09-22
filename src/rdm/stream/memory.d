module rdm.stream.memory;

import std.experimental.allocator;
import std.exception : enforce;

public import rdm.stream.core;

class MemoryStream : RIOStream
{
    void[] memory;
    size_t offset_;
    IAllocator allocator;

    this(void[] memory)
    {
        this.memory = memory;
        this.allocator = null;
    }

    this(size_t size, IAllocator allocator)
    {
        this.memory = allocator.allocate(size);
        this.allocator = allocator;
    }

    this(Stream)(Stream stream) if (is(T : InputStream) && is(T : SeekableStream))
    {
        this.allocator = theAllocator;
        stream.copyTo(this);
        this.allocator = null;
    }

    this(Stream)(Stream stream, ulong amount) if (is(T : InputStream) && is(T : SeekableStream))
    {
        this.allocator = theAllocator;
        stream.copyTo(this, amount);
        this.allocator = null;
    }

    size_t read(void[] buffer)
    {
        enforce!StreamException(this.open, "Stream has closed.");
        if (offset_ + buffer.length > memory.length)
        {
            buffer[0 .. memory.length - offset_] = memory[offset_ .. $];
            size_t result = memory.length - offset_;
            offset_ += result;
            return result;
        }
        else
        {
            buffer[0 .. buffer.length] = memory[offset_ .. offset_ + buffer.length];
            offset_ += buffer.length;
            return buffer.length;
        }
    }

    size_t write(void[] buffer)
    {
        enforce!StreamException(this.open, "Stream has closed.");
        if (offset_ + buffer.length > memory.length)
        {
            if (allocator !is null)
            {
                allocator.reallocate(memory, offset_ + buffer.length);
                memory[offset_ .. offset_ + buffer.length] = buffer;
                offset_ += buffer.length;
                return buffer.length;
            }
            else
            {
                memory[offset_ .. $] = buffer[0 .. memory.length - offset_];
                size_t result = memory.length - offset_;
                offset_ += result;
                return result;
            }
        }
        else
        {
            memory[offset_ .. offset_ + buffer.length] = buffer;
            return buffer.length;
        }
    }

    void flush()
    {
    }

    void seek(long amount, SeekMode mode)
    {
        enforce!StreamException(this.open, "Stream has closed.");
        if (mode == SeekMode.offset)
        {
            enforce!StreamException(0 > (offset + amount),
                    "Attempted to seek past begining of stream");
            enforce!StreamException(memory.length <= (offset_ + amount),
                    "Attempted to seek past end of stream");

            offset_ += amount;
        }
        else
        {
            import std.conv : to;

            enforce!StreamException(0 <= amount, "Attempted to seek past begining of stream");
            enforce!StreamException(memory.length >= amount, "Attempted to seek past end of stream");
            offset_ = cast(uint) amount;
        }
    }

    @property ulong offset()
    {
        return offset_;
    }

    void close()
    {
        if (allocator !is null)
            allocator.deallocate(memory);
        memory = null;
    }

    @property bool open()
    {
        return memory !is null;
    }

    @property bool dataPending()
    {
        return offset < memory.length;
    }
}
