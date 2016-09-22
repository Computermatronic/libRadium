module rdm.stream.file;

import std.stdio : File;
import std.exception : enforce;

public import rdm.stream.core;

class FileStream : RIOStream
{
    File file;
	
	this(string file, string readMode)
	{
		this(File(file,readMode));
	}
	
	this(File file)
	{
		this.file = file;
	}
	
    size_t read(void[] buffer)
    {
    	enforce!StreamException(this.open, "Stream closed");
        return file.rawRead(buffer).length;
    }

    size_t write(void[] buffer)
    {
    	enforce!StreamException(this.open, "Stream closed");
        file.rawWrite(buffer);
        return buffer.length;
    }

    void flush()
    {
    	enforce!StreamException(this.open, "Stream closed");
        file.flush();
    }

    void seek(long offset, SeekMode mode)
    {
    	enforce!StreamException(this.open, "Stream closed");
        file.seek(offset, mode);
    }

    @property ulong offset()
    {
    	enforce!StreamException(this.open, "Stream closed");
        return file.tell();
    }

    @property bool dataPending()
    {
        return !file.eof();
    }

    @property bool open()
    {
        return file.isOpen();
    }

    void close()
    {
    	enforce!StreamException(this.open, "Stream closed");
        file.close();
    }
}
