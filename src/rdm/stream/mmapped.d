module rdm.stream.mmapped;

import std.mmfile;
import std.exception : enforce;

public import rdm.stream.core;

class MMappedStream : RIOStream
{
    alias Mode = MmFile.Mode;
    MmFile mmapped;
    ulong _offset;

    this(InputStream source, ulong amount, Mode mode)
    {
        this(amount, mode);
        source.copyTo(this, amount);
    }

    this(string file, Mode mode)
    {
        this(new MmFile(file, mode, 0, null));
    }

    this(ulong size, Mode mode)
    {
        this(new MmFile(null, mode, size, null));
    }

    this(MmFile mmapped)
    {
        this.mmapped = mmapped;
    }

    size_t read(void[] buffer)
    {
        enforce!StreamException(this.open, "Stream closed");
        if (offset + buffer.length > mmapped.length)
        {
            buffer[0 .. cast(size_t)(offset + buffer.length - mmapped.length)] = mmapped[_offset
                .. mmapped.length];
            return cast(size_t)(offset + buffer.length - mmapped.length);
        }
        else
        {
            buffer[0 .. $] = mmapped[_offset .. _offset + buffer.length];
            return buffer.length;
        }
    }

    size_t write(void[] buffer)
    {
        enforce!StreamException(this.open, "Stream closed");
        if (offset + buffer.length > mmapped.length)
        {
            void[] ptr = mmapped[_offset .. mmapped.length];
            ptr[] = buffer[0 .. cast(size_t)(offset + buffer.length - mmapped.length)];
            return cast(size_t)(offset + buffer.length - mmapped.length);
        }
        else
        {
            void[] ptr = mmapped[_offset .. _offset + buffer.length];
            ptr = buffer[0 .. $];
            return buffer.length;
        }
    }

    void flush()
    {
        enforce!StreamException(this.open, "Stream closed");
        mmapped.flush();
    }

    void seek(long offset, SeekMode mode)
    {
        enforce!StreamException(this.open, "Stream closed");
        if (mode == SeekMode.begining)
        {
            enforce!StreamException(offset < mmapped.length,
                    "Attempted to seek beyond stream bounds");
            _offset = offset;
        }
        else
        {
            enforce!StreamException(_offset + offset > 0
                    && _offset + offset < mmapped.length, "Attempted to seek beyond stream bounds");
            _offset += offset;
        }
    }

    @property ulong offset()
    {
        enforce!StreamException(this.open, "Stream closed");
        return _offset;
    }

    @property bool dataPending()
    {
        enforce!StreamException(this.open, "Stream closed");
        return _offset < mmapped.length();
    }

    @property bool open()
    {
        return mmapped !is null;
    }

    void close()
    {
        enforce!StreamException(this.open, "Stream closed");
        delete mmapped;
        mmapped = null;
    }
}
