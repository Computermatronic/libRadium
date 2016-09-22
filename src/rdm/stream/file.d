module rdm.stream.file;

import std.exception : enforce;
import std.string : toStringz;

public import rdm.stream.core;
import rdm.stream.iohelper;

class FileStream : RIOStream
{
    FILE* file;

    this(string file, string mode)
    {
        this.file = fopen(file.toStringz(), mode.toStringz());
        enforce!StreamException(this.open, "Failed to open file "~file);
    }

    this(FILE* file)
    {
        this.file = file;
    }

    size_t read(void[] buffer)
    {
        enforce!StreamException(this.open, "Stream has closed.");
        return fread(buffer.ptr, 1, buffer.length, file);
    }

    size_t write(void[] buffer)
    {
        enforce!StreamException(this.open, "Stream has closed.");
        return fwrite(buffer.ptr, 1, buffer.length, file);
    }

    void flush()
    {
        fflush(file);
    }

    void seek(long amount, SeekMode mode)
    {
        enforce!StreamException(this.open, "Stream has closed.");
        __fseeki64(file, amount, mode);
    }

    @property ulong offset()
    {
        enforce!StreamException(this.open, "Stream has closed.");
        return __ftelli64(file);
    }

    void close()
    {
        if (this.open)
        {
            fclose(file);
            file = null;
        }
    }
    
    @property bool open()
    {
        return file !is null;
    }

    @property bool dataPending()
    {
        enforce!StreamException(this.open, "Stream has closed.");
        return cast(bool) !feof(file);
    }
}