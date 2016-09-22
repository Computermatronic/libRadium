module rdm.asset.rdarchive;
//
//import std.exception : enforce;
//
//import rdm.stream.core;
//import rdm.stream.memory;
//import rdm.stream.offset;
//
//public enum uint RDArchiveMagicNumber = 0x11BA9A97;
//
//public enum RDArchiveVersion : ubyte
//{
//    RDA100 = 1
//}
//
//public class RDArchive
//{
//    public class RDArchiveMember : RIOStream
//    {
//        string name;
//        uint dataType;
//        ulong size;
//
//        private bool isROMRIOStream;
//        private RIOStream dataStream;
//
//        this(string name, RDArchiveMemberHeader* header)
//        {
//            this.name = name;
//            this.dataType = header.dataType;
//            this.dataStream = new OffsetStream!RIOStream(stream, header.dataOffset);
//            this.isROMRIOStream = true;
//        }
//
//        this(string name, uint dataType, RIOStream dataStream)
//        {
//            this.name = name;
//            this.dataStream = dataStream;
//        }
//
//        size_t read(void[] buffer)
//        {
//            return dataStream.read(buffer);
//        }
//
//        size_t write(void[] buffer)
//        {
//            if (isROMRIOStream)
//            {
//                dataStream = new MemoryStream(dataStream);
//                isROMRIOStream = false;
//            }
//            return dataStream.write(buffer);
//        }
//
//        void seek(long amount, SeekMode mode)
//        {
//            dataStream.seek(amount, mode);
//        }
//
//        void flush()
//        {
//            return dataStream.flush();
//        }
//
//        void close()
//        {
//            return dataStream.close();
//        }
//
//        @property ulong offset()
//        {
//            return dataStream.offset();
//        }
//
//        @property bool dataPending()
//        {
//            return dataStream.dataPending;
//        }
//
//        @property bool open()
//        {
//            return dataStream.open();
//        }
//    }
//
//    RIOStream stream;
//    RDArchiveMember[string] members;
//
//    this()
//    {
//    }
//
//    this(RIOStream stream, bool copyData = true)
//    {
//        ulong dataSize;
//        auto headers = parseHeaders(stream, &dataSize);
//        auto offset_ = stream.offset;
////        if (stream.isBidirectional() && !copyData)
////            this.stream = new SliceRIOStream(stream, offset_, dataSize);
////        else
//            this.stream = new MemoryStream(stream,dataSize);
//        populate(headers);
//    }
//
//    RDArchiveMemberHeader[] parseHeaders(RIOStream dataStream, ulong* dataSize)
//    {
//        auto archiveHeader = dataStream.readAs!RDArchiveHeader();
//        enforce!RDArchiveException(archiveHeader.magicNumber == RDArchiveMagicNumber,
//                "File is not RDArchive!");
//        enforce!RDArchiveException(archiveHeader.archiveVersion == RDArchiveVersion.RDA100,
//                "RDArchive version not supported!");
//        auto memberHeaders = dataStream.readAs!RDArchiveMemberHeader(archiveHeader.memberCount);
//        *dataSize = archiveHeader.dataSize;
//        return memberHeaders;
//    }
//
//    void populate(RDArchiveMemberHeader[] headers)
//    {
//        foreach (header; headers)
//        {
//            stream.seek(header.nameOffset, SeekMode.begining);
//            auto name = stream.readAs!char(header.nameLength).idup();
//            members[name] = new RDArchiveMember(name, &header);
//        }
//    }
//
//    void write(RIOStream stream)
//    {
//        RDArchiveHeader header;
//        header.memberCount = members.length;
//        foreach (member; members)
//        {
//            header.dataSize += member.name.length + member.size;
//        }
//        stream.writeAs(header);
//        ulong offset;
//        foreach (member; members)
//        {
//            RDArchiveMemberHeader memberHeader;
//            memberHeader.nameOffset = offset;
//            offset += memberHeader.nameLength = cast(ushort) member.name.length;
//            memberHeader.dataOffset = offset;
//            offset += memberHeader.dataLength = member.size;
//            stream.writeAs(memberHeader);
//        }
//        foreach (member; members)
//        {
//            stream.bufferedWrite(cast(void[]) member.name);
//            member.seek(0, SeekMode.begining);
//            member.writeTo(stream);
//        }
//    }
//
//    void add(string name, uint dataType, RIOStream dataStream)
//    {
//        members[name] = new RDArchiveMember(name, dataType, dataStream);
//    }
//}
//
//class RDArchiveException : Exception
//{
//	@nogc @safe pure nothrow this(string msg, string file = __FILE__,
//		size_t line = __LINE__, Throwable next = null)
//	{
//		super(msg, file, line, next);
//	}
//}
//
//private struct RDArchiveHeader
//{
//	uint magicNumber = RDArchiveMagicNumber;
//	ubyte archiveVersion = RDArchiveVersion.RDA100;
//	uint memberCount;
//	ulong dataSize;
//}
//
//private struct RDArchiveMemberHeader
//{
//	ulong nameOffset;
//	ushort nameLength;
//	
//	uint dataType;
//	ulong dataOffset;
//	ulong dataLength;
//}