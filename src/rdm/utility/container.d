module rdm.utility.container;

struct UnorderdSet(T)
{
    alias Nothing = void[0];

    Nothing[T] set;

    auto opAssign(string op)(T element) if (op == "~=")
    {
        return add(element);
    }

    auto add(T element)
    {
        set[element] = Nothing.init;
        return element;
    }

    auto remove(T element)
    {
        set.remove(element);
    }

    @property size_t length()
    {
        return set.length;
    }

    int opApply(int delegate(T) dg)
    {
        int result;
        
        foreach (k, v; set)
            if ((result = dg(k)) != 0)
                break;
        return result;
    }
}
