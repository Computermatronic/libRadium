module rdm.asset.rddatalang;

import std.exception : enforce;
import std.format;

import std.uni : isNumber, isAlpha;
import std.array : Appender;

public enum RDDataLangType
{
    stringType,
    integerType,
    floatingType,
    arrayType,
    objectType,
    binaryType
}

struct RDDataLangValue
{
    alias as this;

    union
    {
        string _string;
        long _integer;
        real _floating;
        RDDataLangValue[] _array;
        RDDataLangValue[string] _object;
        void[] _binary;
    }

    RDDataLangType type;

    this(T)(T t)
    {
        static if (is(T == string))
        {
            type = RDDataLangType.stringType;
            _string = t;
        }
        else static if (is(T == long))
        {
            type = RDDataLangType.integerType;
            _integer = t;
        }
        else static if (is(T == real))
        {
            type = RDDataLangType.floatingType;
            _floating = t;
        }
        else static if (is(T == RDDataLangValue[]))
        {
            type = RDDataLangType.arrayType;
            _array = t;
        }
        else static if (is(T == RDDataLangValue[string]))
        {
            type = RDDataLangType.objectType;
            _object = t;
        }
        else static if (is(T == void[]))
        {
            type = RDDataLangType.binaryType;
            _binary = t;
        }
        else
            static assert(0, "Incompatable Type for RDDataLangValue");
    }

    auto get(T)()
    {
        static if (is(T == string))
        {
            enforce!RDDataLangException(type == RDDataLangType.stringType,
                    format("RDMarkupValue of %s cannot be used as a %s", type, T.stringof));
            return _string;
        }
        else static if (is(T == long))
        {
            enforce!RDDataLangException(type == RDDataLangType.integerType,
                    format("RDMarkupValue of %s cannot be used as a %s", type, T.stringof));
            return _integer;
        }
        else static if (is(T == real))
        {
            enforce!RDDataLangException(type == RDDataLangType.floatingType,
                    format("RDMarkupValue of %s cannot be used as a %s", type, T.stringof));
            return _floating;
        }
        else static if (is(T == RDDataLangValue[]))
        {
            enforce!RDDataLangException(type == RDDataLangType.arrayType,
                    format("RDMarkupValue of %s cannot be used as a %s", type, T.stringof));
            return _array;
        }
        else static if (is(T == RDDataLangValue[string]))
        {
            enforce!RDDataLangException(type == RDDataLangType.objectType,
                    format("RDMarkupValue of %s cannot be used as a %s", type, T.stringof));
            return _object;
        }
        else static if (is(T == void[]))
        {
            enforce!RDDataLangException(type == RDDataLangType.binaryType,
                    format("RDMarkupValue of %s cannot be used as a %s", type, T.stringof));
            return _binary;
        }
        else
            static assert(0, "Incompatable Type for RDDataLangValue");
    }

    auto set(T)(T t)
    {
        static if (is(T == string))
        {
            enforce!RDDataLangException(type == RDDataLangType.stringType,
                    format("RDMarkupValue of %s cannot be used as a %s", type, T.stringof));
            return _string = t;
        }
        else static if (is(T == long))
        {
            enforce!RDDataLangException(type == RDDataLangType.integerType,
                    format("RDMarkupValue of %s cannot be used as a %s", type, T.stringof));
            return _integer = t;
        }
        else static if (is(T == real))
        {
            enforce!RDDataLangException(type == RDDataLangType.floatingType,
                    format("RDMarkupValue of %s cannot be used as a %s", type, T.stringof));
            return _floating = t;
        }
        else static if (is(T == RDDataLangValue[]))
        {
            enforce!RDDataLangException(type == RDDataLangType.arrayType,
                    format("RDMarkupValue of %s cannot be used as a %s", type, T.stringof));
            return _array = t;
        }
        else static if (is(T == RDDataLangValue[string]))
        {
            enforce!RDDataLangException(type == RDDataLangType.objectType,
                    format("RDMarkupValue of %s cannot be used as a %s", type, T.stringof));
            return _object = t;
        }
        else static if (is(T == void[]))
        {
            enforce!RDDataLangException(type == RDDataLangType.binaryType,
                    format("RDMarkupValue of %s cannot be used as a %s", type, T.stringof));
            return _binary = t;
        }
        else
            static assert(0, "Incompatable Type for RDDataLangValue");
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

//RDDataLangValue[string] parseRDDataLang(T)(T input)
//{
//	string parseString()
//	{
//		enforce!RDDataLangException(popChar == '"');
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
//	RDDataLangValue[] parseArray()
//	{
//		enforce!RDDataLangException(popChar == '[');
//		dchar c;
//		Appender!(RDDataLangValue[]) data;
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
//		enforce!RDDataLangException(popChar == ']');
//
//		return data.data;
//	}
//
//	RDDataLangValue[string] parseObject()
//	{
//		enforce(popChar == '{');
//		dchar c;
//		RDDataLangValue[string] data;
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
//		enforce!RDDataLangException(popChar == ';');
//		return data;
//	}
//
//	RDDataLangValue parseElement()
//	{
//		dchar c = peekChar();
//		if (c == '"')
//			return RDDataLangValue(parseString());
//		else if (c.isAlpha())
//			return RDDataLangValue(parseIdentifier());
//		if (c.isNumber())
//		{
//			auto result = parseNumber();
//			if (result[2])
//				return RDDataLangValue(result[1]);
//			else
//				return RDDataLangValue(result[0]);
//		}
//		if (c == '[')
//			return RDDataLangValue(parseArray());
//		if (c == '{')
//			return RDDataLangValue(parseObject);
//		throw new 
//	}
//
//}

class RDDataLangException : Exception
{
	@nogc @safe pure nothrow this(string msg, string file = __FILE__,
		size_t line = __LINE__, Throwable next = null)
	{
		super(msg, file, line, next);
	}
}
