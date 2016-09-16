module radium.streams.slicestream;

import radium.streams.utils;
public import radium.streams.stream;

class SliceStream : Stream
{
    Stream stream;
    ulong start, offset_, length;

    this(Stream stream, ulong start, ulong length)
    {
        enforce!StreamException(stream.isBidirectional(), "Cannot slice non-bidirectional stream");
        this.stream = stream;
        this.start = start;
        this.length = length;
    }

    size_t read(void[] buffer)
    {
        enforce!StreamException(stream !is null, "Stream has closed.");
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
        enforce!StreamException(stream !is null, "Stream has closed.");
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

    void seek(long amount, SeekMode mode)
    {
        enforce!StreamException(stream !is null, "Stream has closed.");
        if (mode == SeekMode.begining)
            offset_ = amount;
        else
            offset_ += amount;
    }

    void flush()
    {
        stream.flush();
    }

    void close()
    {
        stream = null;
    }

    @property ulong offset()
    {
        enforce!StreamException(stream !is null, "Stream has closed.");
        return offset_;
    }

    @property bool hasEnded()
    {
        enforce!StreamException(stream !is null, "Stream has closed.");
        bool result;
        ulong offset_old = stream.offset;
        stream.seek(start + offset_, SeekMode.begining);
        result = stream.hasEnded();
        stream.seek(offset_old, SeekMode.begining);
        return result;
    }

    @property bool isOpen()
    {
        return stream !is null && stream.isOpen();
    }

    @property bool isBidirectional()
    {
        return true;
    }
}
