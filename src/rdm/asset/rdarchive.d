module rdm.asset.rdarchive;

import std.exception : enforce;

import rdm.stream.mmapped;
import rdm.stream.slice;

public enum uint RDArchiveMagicNumber = 0x11BA9A97;

public enum RDArchiveVersion : ubyte
{
    RDA100 = 1
}

public class RDArchive
{
    public class RDArchiveMember : RIOStream
    {
        string name;
        uint dataType;
        ulong size;

        private bool isROMStream;
        private RIOStream dataStream;
        private ulong dataLength;

        this(string name, RDArchiveMemberHeader* header)
        {
            this.name = name;
            this.dataType = header.dataType;
            this.dataStream = new SliceStream(stream, header.dataOffset, header.dataLength);
            this.dataLength = header.dataLength;
            this.isROMStream = true;
        }

        this(string name, uint dataType, RIOStream dataStream)
        {
            this.name = name;
            this.dataStream = dataStream;
        }

        size_t read(void[] buffer)
        {
            return dataStream.read(buffer);
        }

        size_t write(void[] buffer)
        {
            if (isROMStream)
            {
                dataStream = new MMappedStream(dataStream, dataLength,
                        MMappedStream.Mode.readWrite);
                isROMStream = false;
            }
            return dataStream.write(buffer);
        }

        void seek(long amount, SeekMode mode)
        {
            return dataStream.seek(amount, mode);
        }

        void flush()
        {
            return dataStream.flush();
        }

        void close()
        {
            return dataStream.close();
        }

        @property ulong offset()
        {
            return dataStream.offset();
        }

        @property bool dataPending()
        {
            return dataStream.dataPending();
        }

        @property bool open()
        {
            return dataStream.open();
        }
    }

    RIOStream stream;
    RDArchiveMember[string] members;

    this()
    {
    }

    this(InputStream stream, bool copyData = true)
    {
        ulong dataSize;
        auto headers = parseHeaders(stream, &dataSize);
        this.stream = new MMappedStream(stream, dataSize, MMappedStream.Mode.readWrite);
        populate(headers);
    }

    RDArchiveMemberHeader[] parseHeaders(InputStream dataStream, ulong* dataSize)
    {
        auto archiveHeader = dataStream.readAs!RDArchiveHeader();
        enforce!RDArchiveException(archiveHeader.magicNumber == RDArchiveMagicNumber,
                "File is not RDArchive!");
        enforce!RDArchiveException(archiveHeader.archiveVersion == RDArchiveVersion.RDA100,
                "RDArchive version not supported!");
        auto memberHeaders = dataStream.readAs!RDArchiveMemberHeader(archiveHeader.memberCount);
        *dataSize = archiveHeader.dataSize;
        return memberHeaders;
    }

    void populate(RDArchiveMemberHeader[] headers)
    {
        foreach (header; headers)
        {
            stream.seek(header.nameOffset, SeekMode.begining);
            auto name = stream.readAs!char(header.nameLength).idup();
            members[name] = new RDArchiveMember(name, &header);
        }
    }

    void write(OutputStream stream)
    {
        RDArchiveHeader header;
        header.memberCount = members.length;
        foreach (member; members)
        {
            header.dataSize += member.name.length + member.size;
        }
        stream.writeAs(header);
        ulong offset;
        foreach (member; members)
        {
            RDArchiveMemberHeader memberHeader;
            memberHeader.nameOffset = offset;
            offset += memberHeader.nameLength = cast(ushort) member.name.length;
            memberHeader.dataOffset = offset;
            offset += memberHeader.dataLength = member.size;
            stream.writeAs(memberHeader);
        }
        foreach (member; members)
        {
            stream.write(cast(void[]) member.name);
            member.seek(0, SeekMode.begining);
            member.copyTo(stream);
        }
    }

    void add(string name, uint dataType, RIOStream dataStream)
    {
        members[name] = new RDArchiveMember(name, dataType, dataStream);
    }
}

class RDArchiveException : Exception
{
    @nogc @safe pure nothrow this(string msg, string file = __FILE__,
            size_t line = __LINE__, Throwable next = null)
    {
        super(msg, file, line, next);
    }
}

private struct RDArchiveHeader
{
    uint magicNumber = RDArchiveMagicNumber;
    ubyte archiveVersion = RDArchiveVersion.RDA100;
    uint memberCount;
    ulong dataSize;
}

private struct RDArchiveMemberHeader
{
    ulong nameOffset;
    ushort nameLength;

    uint dataType;
    ulong dataOffset;
    ulong dataLength;
}
