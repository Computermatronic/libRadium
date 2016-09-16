module radium.assets.rddatamarkup;

import std.exception : enforce;
import std.format;

import std.uni : isNumber, isAlpha;
import std.array : Appender;

public enum RDDataMarkupType
{
    stringType,
    integerType,
    floatingType,
    arrayType,
    objectType,
    binaryType
}

struct RDDataMarkupValue
{
    alias as this;

    union
    {
        string _string;
        long _integer;
        real _floating;
        RDDataMarkupValue[] _array;
        RDDataMarkupValue[string] _object;
        void[] _binary;
    }

    RDDataMarkupType type;

    this(T)(T t)
    {
        static if (is(T == string))
        {
            type = RDDataMarkupType.stringType;
            _string = t;
        }
        else static if (is(T == long))
        {
            type = RDDataMarkupType.integerType;
            _integer = t;
        }
        else static if (is(T == real))
        {
            type = RDDataMarkupType.floatingType;
            _floating = t;
        }
        else static if (is(T == RDDataMarkupValue[]))
        {
            type = RDDataMarkupType.arrayType;
            _array = t;
        }
        else static if (is(T == RDDataMarkupValue[string]))
        {
            type = RDDataMarkupType.objectType;
            _object = t;
        }
        else static if (is(T == void[]))
        {
            type = RDDataMarkupType.binaryType;
            _binary = t;
        }
        else
            static assert(0, "Incompatable Type for RDDataMarkupValue");
    }

    auto get(T)()
    {
        static if (is(T == string))
        {
            enforce!RDDataMarkupException(type == RDDataMarkupType.stringType,
                    format("RDMarkupValue of %s cannot be used as a %s", type, T.stringof));
            return _string;
        }
        else static if (is(T == long))
        {
            enforce!RDDataMarkupException(type == RDDataMarkupType.integerType,
                    format("RDMarkupValue of %s cannot be used as a %s", type, T.stringof));
            return _integer;
        }
        else static if (is(T == real))
        {
            enforce!RDDataMarkupException(type == RDDataMarkupType.floatingType,
                    format("RDMarkupValue of %s cannot be used as a %s", type, T.stringof));
            return _floating;
        }
        else static if (is(T == RDDataMarkupValue[]))
        {
            enforce!RDDataMarkupException(type == RDDataMarkupType.arrayType,
                    format("RDMarkupValue of %s cannot be used as a %s", type, T.stringof));
            return _array;
        }
        else static if (is(T == RDDataMarkupValue[string]))
        {
            enforce!RDDataMarkupException(type == RDDataMarkupType.objectType,
                    format("RDMarkupValue of %s cannot be used as a %s", type, T.stringof));
            return _object;
        }
        else static if (is(T == void[]))
        {
            enforce!RDDataMarkupException(type == RDDataMarkupType.binaryType,
                    format("RDMarkupValue of %s cannot be used as a %s", type, T.stringof));
            return _binary;
        }
        else
            static assert(0, "Incompatable Type for RDDataMarkupValue");
    }

    auto set(T)(T t)
    {
        static if (is(T == string))
        {
            enforce!RDDataMarkupException(type == RDDataMarkupType.stringType,
                    format("RDMarkupValue of %s cannot be used as a %s", type, T.stringof));
            return _string = t;
        }
        else static if (is(T == long))
        {
            enforce!RDDataMarkupException(type == RDDataMarkupType.integerType,
                    format("RDMarkupValue of %s cannot be used as a %s", type, T.stringof));
            return _integer = t;
        }
        else static if (is(T == real))
        {
            enforce!RDDataMarkupException(type == RDDataMarkupType.floatingType,
                    format("RDMarkupValue of %s cannot be used as a %s", type, T.stringof));
            return _floating = t;
        }
        else static if (is(T == RDDataMarkupValue[]))
        {
            enforce!RDDataMarkupException(type == RDDataMarkupType.arrayType,
                    format("RDMarkupValue of %s cannot be used as a %s", type, T.stringof));
            return _array = t;
        }
        else static if (is(T == RDDataMarkupValue[string]))
        {
            enforce!RDDataMarkupException(type == RDDataMarkupType.objectType,
                    format("RDMarkupValue of %s cannot be used as a %s", type, T.stringof));
            return _object = t;
        }
        else static if (is(T == void[]))
        {
            enforce!RDDataMarkupException(type == RDDataMarkupType.binaryType,
                    format("RDMarkupValue of %s cannot be used as a %s", type, T.stringof));
            return _binary = t;
        }
        else
            static assert(0, "Incompatable Type for RDDataMarkupValue");
    }

    @property auto as(T)()
    {
        return get!T();
    }

    @property auto as(T)(T t)
    {
        return set!T(t);
    }
}

//RDDataMarkupValue[string] parseRDDataMarkup(T)(T input)
//{
//	string parseString()
//	{
//		enforce!RDDataMarkupException(popChar == '"');
//		Appender!string data;
//		dchar c;
//		while((c = popChar) != '"')
//		{
//			if (c == '\\')
//			{
//				switch(c = popChar)
//				{
//					case '\\':
//						data.put('\\');
//						break;
//					case 'r':
//						data.put('\r');
//						break;
//					case 'n':
//						data.put('\n');
//						break;
//					case '"':
//						data.put('"');
//						break;
//					default:
//						data.put("\\\\");
//				}
//			}
//			else
//				data.put(c);
//		}
//		return data.data;
//	}
//
//	Tuple!(long,double,bool) parseNumber()
//	{
//		dchar c;
//		Appender!string data;
//		bool isFloat;
//		while((c = popChar).isNumber() || (c == '.' && !isFloat))
//		{
//			data.put(c);
//		}
//
//		if (isFloat)
//			return tuple(0, to!double(data.data),isFloat);
//		else
//			return tuple(to!long(data.data), float.nan, isFloat);
//	}
//
//	RDDataMarkupValue[] parseArray()
//	{
//		enforce!RDDataMarkupException(popChar == '[');
//		dchar c;
//		Appender!(RDDataMarkupValue[]) data;
//		if (peekChar == ']')
//		{
//			popChar();
//			return data.data;
//		}
//		do
//		{
//			data.put(parseElement());
//		}
//		while(popChar == ',');
//		enforce!RDDataMarkupException(popChar == ']');
//
//		return data.data;
//	}
//
//	RDDataMarkupValue[string] parseObject()
//	{
//		enforce(popChar == '{');
//		dchar c;
//		RDDataMarkupValue[string] data;
//		if (peekChar == '}')
//		{
//			popChar();
//			return data.data;
//		}
//		do
//		{
//			auto id = parseIdentifier();
//			enforce(popChar == ':');
//			data[id] = parseElement();
//		}
//		while(popChar == ',');
//		enforce!RDDataMarkupException(popChar == ';');
//		return data;
//	}
//
//	RDDataMarkupValue parseElement()
//	{
//		dchar c = peekChar();
//		if (c == '"')
//			return RDDataMarkupValue(parseString());
//		else if (c.isAlpha())
//			return RDDataMarkupValue(parseIdentifier());
//		if (c.isNumber())
//		{
//			auto result = parseNumber();
//			if (result[2])
//				return RDDataMarkupValue(result[1]);
//			else
//				return RDDataMarkupValue(result[0]);
//		}
//		if (c == '[')
//			return RDDataMarkupValue(parseArray());
//		if (c == '{')
//			return RDDataMarkupValue(parseObject);
//		throw new 
//	}
//
//}

class RDDataMarkupException : Exception
{
	@nogc @safe pure nothrow this(string msg, string file = __FILE__,
		size_t line = __LINE__, Throwable next = null)
	{
		super(msg, file, line, next);
	}
}
