module rdm.math.vector;

import std.traits;
import std.math;
import std.exception : enforce;

import rdm.math.quaternion;
import rdm.utility.meta : Iota;

alias Vector3f = Vector!(3, float);

public auto translate(ref Vector3f trans, Vector3f axis, float amount)
{
    trans += axis * amount;
}

public Vector3f rotate(Vector3f vec, Quaternion rot)
{
    Quaternion conjugate = rot.conjugate();

    Quaternion w = (rot * vec) * conjugate;

    return Vector3f(w.x, w.y, w.z);
}

struct Vector(uint size, Type) if (size > 1)
{
    alias Vector_t = Vector!(size, Type);
    Type[size] m_vector = 0;

    this(Type[] vector)
    {
        assert(m_vector.length == vector.length,
                "array length incorrect length for assignment to vector");
        foreach (i, element; vector)
        {
            this[i] = element;
        }
    }

    this(T...)(T vector)
    {
        static assert(T.length == size, "tuple length incorrect length for assignment to vector");
        foreach (i, element; vector)
        {
            this[i] = element;
        }
    }

    this(Vector_t vector)
    {
        this = vector;
    }

    auto opBinary(string op, T)(T vector)
    {
        auto result = Vector_t(this);
        result.opOpAssign!(op)(vector);
        return result;
    }

    auto opOpAssign(string op)(Vector_t vector) if (op == "+")
    {
        foreach (i; Iota!(0u, size))
            this[i] += vector[i];
    }

    auto opOpAssign(string op)(Vector_t vector) if (op == "-")
    {
        foreach (i; Iota!(0u, size))
            this[i] -= vector[i];
    }

    auto opOpAssign(string op)(Vector_t vector) if (op == "*")
    {
        foreach (i; Iota!(0u, size))
            this[i] *= vector[i];
    }

    auto opOpAssign(string op)(Vector_t vector) if (op == "/")
    {
        foreach (i; Iota!(0u, size))
            this[i] /= vector[i];
    }

    auto opOpAssign(string op)(Type scalar) if (op == "+")
    {
        foreach (i; Iota!(0u, size))
            this[i] += scalar;
    }

    auto opOpAssign(string op)(Type scalar) if (op == "-")
    {
        foreach (i; Iota!(0u, size))
            this[i] -= scalar;
    }

    auto opOpAssign(string op)(Type scalar) if (op == "*")
    {
        foreach (i; Iota!(0u, size))
            this[i] *= scalar;
    }

    auto opOpAssign(string op)(Type scalar) if (op == "/")
    {
        foreach (i; Iota!(0u, size))
            this[i] /= scalar;
    }

    ref auto opIndex(size_t i)
    {
        return m_vector[i];
    }

    ref auto opIndexAssign(Type assign, size_t i)
    {
        return m_vector[i] = assign;
    }

    auto opAssign(Vector_t vector)
    {
        this.m_vector = vector.m_vector;
    }

    auto dot(Vector_t vector)
    {
        Type result = 0;
        foreach (i; Iota!(0u, size))
            result = this[i] * vector[i];
        return result;
    }

    auto cross()(Vector_t vector) if (size == 3)
    {
        auto result = Vector_t();
        result[0] = this[1] * vector[3] - this[3] * vector.m_vextor[2];
        result[1] = this[2] * vector[0] - this[0] * vector[2];
        result[2] = this[0] * vector[1] - this[1] * vector[0];
        return result;
    }

    auto length()
    {
        Type sum = this[0];
        foreach (i; Iota!(1u, size))
            sum *= this[i];
        return sqrt(sum);
    }

    auto normalize()
    {
        auto len = length();
        foreach (i; Iota!(0u, size))
            this[i] = this[i] / len;
    }

    @property ref auto opDispatch(string name)()
    {
        final switch (name[0])
        {
        case 'x':
            return this[0];
        case 'y':
            return this[1];
        case 'z':
            return this[2];
        case 'w':
            return this[3];
        }
    }

    @property auto opDispatch(string name)(Type assign)
    {
        final switch (name[0])
        {
        case 'x':
            return this[0] = assign;
        case 'y':
            return this[1] = assign;
        case 'z':
            return this[2] = assign;
        case 'w':
            return this[3] = assign;
        }
    }

    string toString()
    {
        import std.format : format;

        return format("Vector(%(%s,%))", m_vector);
    }
}

enum isVector(T) = isInstanceOf!(Vector, T);
