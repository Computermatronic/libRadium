module rdm.utility.meta;

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