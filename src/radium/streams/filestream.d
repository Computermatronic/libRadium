module radium.streams.filestream;

import std.string;
import radium.streams.utils;
import radium.streams.iohelper;

public import radium.streams.stream;

__gshared public FileStream inStream, outStream, errStream;

shared static this()
{
//    inStream = new FileStream(stdin);
//    outStream = new FileStream(stdout);
//    errStream = new FileStream(stderr);
}

class FileStream : Stream
{
    FILE* file;

    this(string file, string mode)
    {
        this.file = fopen(file.toStringz(), mode.toStringz());
        enforce!StreamException(file !is null, "Failed to open file "~file);
    }

    this(FILE* file)
    {
        this.file = file;
    }

    size_t read(void[] buffer)
    {
        enforce!StreamException(file !is null, "Stream has closed.");
        return fread(buffer.ptr, 1, buffer.length, file);
    }

    size_t write(void[] buffer)
    {
        enforce!StreamException(file !is null, "Stream has closed.");
        return fwrite(buffer.ptr, 1, buffer.length, file);
    }

    void seek(long amount, SeekMode mode)
    {
        enforce!StreamException(file !is null, "Stream has closed.");
        __fseeki64(file, amount, mode);
    }

    void flush()
    {
        fflush(file);
    }

    void close()
    {
        if (file !is null)
        {
            fclose(file);
            file = null;
        }
    }

    @property ulong offset()
    {
        enforce!StreamException(file !is null, "Stream has closed.");
        return __ftelli64(file);
    }

    @property bool hasEnded()
    {
        enforce!StreamException(file !is null, "Stream has closed.");
        return cast(bool) feof(file);
    }

    @property bool isOpen()
    {
        return file !is null;
    }

    @property bool isBidirectional()
    {
        return true;
    }
}