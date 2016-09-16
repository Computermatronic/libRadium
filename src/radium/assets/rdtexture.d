module radium.assets.rdtexture;

import std.exception : enforce;

import radium.streams.stream;

public enum uint RDTextureMagicNumber = 0xF0DDE7F1;

public enum RDTextureVersion : ubyte
{
    RDT100 = 1
}

enum RDTexturePixelFormat : ubyte
{
    RGBAi8,
    RGBAi16,
    RGBAi32,
    RGBAf32,
}

struct RDTexturePixelRGBAi8
{
    enum RDTexturePixelFormat format = RDTexturePixelFormat.RGBAi8;
    ubyte r, g, b, a;
}

struct RDTexturePixelRGBAi16
{
    enum RDTexturePixelFormat format = RDTexturePixelFormat.RGBAi16;
    ushort r, g, b, a;
}

struct RDTexturePixelRGBAi32
{
    enum RDTexturePixelFormat format = RDTexturePixelFormat.RGBAi32;
    uint r, g, b, a;
}

struct RDTexturePixelRGBAf32
{
    enum RDTexturePixelFormat format = RDTexturePixelFormat.RGBAf32;
    float r, g, b, a;
}

class RDTexture
{
    void[] pixels;
    uint width, height;
    immutable RDTexturePixelFormat pixelFormat;

    this(Stream stream)
    {
        auto header = stream.readAs!RDTextureHeader();
        enforce!RDTextureException(header.magicNumber == RDTextureMagicNumber,
                "File is not RDTexture!");
        enforce!RDTextureException(header.textureVersion == RDTextureVersion.RDT100,
                "RDTexture version not supported!");
        enforce!RDTextureException(header.pixelFormat == RDTexturePixelFormat.RGBAi8
                || header.pixelFormat == RDTexturePixelFormat.RGBAi16
                || header.pixelFormat == RDTexturePixelFormat.RGBAi32
                || header.pixelFormat == RDTexturePixelFormat.RGBAf32, "Invalid pixel format");

        pixelFormat = cast(RDTexturePixelFormat) header.pixelFormat;
        width = header.textureWidth;
        height = header.textureHeight;
        pixels = stream.bufferedRead(width * height * pixelSize(pixelFormat));
    }

    T opIndex(T)(uint x, uint y)
    {
        static assert(T == RDTexturePixelRGBAi8 || T == RDTexturePixelRGBAi16
                || T == RDTexturePixelRGBAi32 || T == RDTexturePixelRGBAf32,
                "Argument must be a RDTexturePixel");
        enforce!RDTextureException(T.format == pixelFormat,
                "attempted to read pixel with wrong pixel format");
        return *cast(T*) pixels[(x * width + y) * T.sizeof].ptr;
    }
}

class RDTextureException : Exception
{
	@nogc @safe pure nothrow this(string msg, string file = __FILE__,
		size_t line = __LINE__, Throwable next = null)
	{
		super(msg, file, line, next);
	}
}

private struct RDTextureHeader
{
	uint magicNumber;
	ubyte textureVersion;
	ubyte pixelFormat;
	uint textureWidth;
	uint textureHeight;
}

private size_t pixelSize(RDTexturePixelFormat format)
{
	final switch (format) with (RDTexturePixelFormat)
	{
		case RGBAi8:
			return RDTexturePixelRGBAi8.sizeof;
		case RGBAi16:
			return RDTexturePixelRGBAi16.sizeof;
		case RGBAi32:
			return RDTexturePixelRGBAi32.sizeof;
		case RGBAf32:
			return RDTexturePixelRGBAf32.sizeof;
	}
}