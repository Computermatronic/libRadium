module rdm.stream.slice;

import std.exception : enforce;

public import rdm.stream.core;

class SliceStream : RIOStream
{
    RIOStream stream;
    ulong start, offset_, length;

    this(RIOStream stream, ulong start, ulong length)
    {
        this.stream = stream;
        this.start = start;
        this.length = length;
    }

    size_t read(void[] buffer)
    {
        enforce!StreamException(this.open, "Stream closed");
        size_t result;
        ulong offset_old = stream.offset;
        stream.seek(start + offset_, SeekMode.begining);
        if (offset_ + buffer.length > length)
            result = stream.read(buffer[0 .. cast(size_t)(offset - length)]);
        else
            result = stream.read(buffer);
        offset_ += result;
        stream.seek(offset_old, SeekMode.begining);
        return result;
    }

    size_t write(void[] buffer)
    {
        enforce!StreamException(this.open, "Stream closed");
        size_t result;
        ulong offset_old = stream.offset;
        stream.seek(start + offset_, SeekMode.begining);
        if (offset_ + buffer.length > length)
            result = stream.write(buffer[0 .. cast(size_t)(offset - length)]);
        else
            result = stream.write(buffer);
        offset_ += result;
        stream.seek(offset_old, SeekMode.begining);
        return result;
    }

    void flush()
    {
        stream.flush();
    }

    void seek(long amount, SeekMode mode)
    {
        enforce!StreamException(this.open, "Stream closed");
        if (mode == SeekMode.begining)
            offset_ = amount;
        else
            offset_ += amount;
    }

    @property ulong offset()
    {
        enforce!StreamException(this.open, "Stream closed");
        return offset_;
    }

    @property bool dataPending()
    {
        enforce!StreamException(this.open, "Stream closed");
        bool result;
        ulong offset_old = stream.offset;
        stream.seek(start + offset_, SeekMode.begining);
        result = stream.dataPending;
        stream.seek(offset_old, SeekMode.begining);
        return result;
    }

    @property bool open()
    {
        return stream !is null && stream.open();
    }

    void close()
    {
        stream = null;
    }
}
