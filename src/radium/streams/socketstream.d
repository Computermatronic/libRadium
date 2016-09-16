module radium.streams.socketstream;

import std.socket;

public import radium.streams.stream;
/+
class SocketStream : Stream
{
     read(void[] buffer);
     write(void[] buffer);

    void seek(ptrdiff_t amount, SeekMode mode);
    void close();

    @property  offset();
    @property bool hasEnded();
    @property bool isOpen();
    @property bool isBidirectional()
    {
    	return false;
    }
}
+/