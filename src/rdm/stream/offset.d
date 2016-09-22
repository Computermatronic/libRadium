module rdm.stream.offset;

import std.exception : enforce;

public import rdm.stream.core;

template OffsetStream(T) if (is(T : SeekableStream))
{
    static import std.forma;

    enum _isInputStream = is(T : InputStream);
    enum _isOutputStream = is(T : OutputStream);

    static if (is(T : RIOStream))
        mixin(std.format.format(_code, "RIOStream"));
    else static if (is(T : RIStream))
        mixin(std.format.format(_code, "RIStream"));
    else static if (is(T : ROStream))
        mixin(std.format.format(_code, "ROStrem"));

    enum _code = q{
    class OffsetStream : %s
    {
        Stream stream;
        ulong start, offset_;

        this(Stream stream, ulong start)
        {
            this.stream = stream;
            this.start = start;
        }

        static if (_isInputStream)
            size_t read(void[] buffer)
            {
                enforce!StreamException(this.open, "Stream has closed.");
                size_t result;
                ulong offset_old = stream.offset;
                stream.seek(start + offset_, SeekMode.begining);
                result = stream.read(buffer);
                offset_ += result;
                stream.seek(offset_old, SeekMode.begining);
                return result;
            }

        static if (_isOutputStream)
            size_t write(void[] buffer)
            {
                enforce!StreamException(this.open, "Stream has closed.");
                size_t result;
                ulong offset_old = stream.offset;
                stream.seek(start + offset_, SeekMode.begining);
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
            enforce!StreamException(this.open, "Stream has closed.");
            if (mode == SeekMode.begining)
                offset_ = amount;
            else
                offset_ += amount;
        }

        @property ulong offset()
        {
            enforce!StreamException(this.open, "Stream has closed.");
            return offset_;
        }

        void close()
        {
            stream = null;
        }

        @property bool open()
        {
            return stream !is null && stream.open();
        }

        @property bool dataPending()
        {
            enforce!StreamException(this.open, "Stream has closed.");
            bool result;
            ulong offset_old = stream.offset;
            stream.seek(start + offset_, SeekMode.begining);
            result = stream.dataPending();
            stream.seek(offset_old, SeekMode.begining);
            return !result;
        }
    }};
}
