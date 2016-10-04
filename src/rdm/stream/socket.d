module rdm.stream.socket;

import std.exception : enforce;
import std.socket;

public import rdm.stream.core;

class SocketStream : IOStream
{
    Socket socket;

    void[4] buffer;
    void[] inBuffer;

    this(Socket socket)
    {
        this.socket = socket;
    }

    size_t read(void[] buffer)
    {
        enforce!StreamException(this.open, "Stream closed");
        if (inBuffer.length <= 0)
            return socket.receive(buffer);
        else
        {
            buffer[0 .. inBuffer.length] = inBuffer[0 .. $];
            size_t amountRead = inBuffer.length + socket.receive(buffer[inBuffer.length .. $]);
            inBuffer = null;
            return amountRead;
        }
    }

    size_t write(void[] buffer)
    {
        enforce!StreamException(this.open, "Stream closed");
        return socket.send(buffer);
    }

    void flush()
    {
        enforce!StreamException(this.open, "Stream closed");
    }

    @property bool dataPending()
    {
        enforce!StreamException(this.open, "Stream closed");
        if (inBuffer !is null)
            return true;
        auto amountRead = socket.receive(buffer);
        inBuffer = buffer[0 .. amountRead];
        return amountRead > 0;
    }

    @property bool open()
    {
        return socket.isAlive();
    }

    void close()
    {
        enforce!StreamException(this.open, "Stream closed");
        socket.close();
    }
}
