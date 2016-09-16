module radium.utility.meta;

import std.traits : ReturnType;

public template Iota(size_t a, size_t b)
{
    import std.typetuple;

    static if (a < b)
    {
        alias Iota = TypeTuple!(a, Iota!(a + 1, b));
    }
    else
    {
		alias Iota = TypeTuple!();
    }
}

public template ArrayElementType(T)
{
    alias ArrayElementType = typeof(T.init[0]);
}

public struct ProcessedArray(T,alias outFun)
{
	private alias ProcessedType = ReturnType!outFun;

	private T _data;

	this(T[] data)
	{
		_data = data;
	}

	@property size_t length()
	{
		return _data;
	}

	@property size_t length(size_t newLength)
	{
		return _data.length = newLength;
	}

	ProcessedType opIndex(size_t index)
	{
		return outFun(_data[index]);
	}
}