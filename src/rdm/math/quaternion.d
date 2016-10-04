module rdm.math.quaternion;

import std.math;

import rdm.math.vector;
import rdm.math.matrix;

struct Quaternion
{
    float x = 0;
    float y = 0;
    float z = 0;
    float w = 1;

    public this(float x, float y, float z, float w)
    {
        this.x = x;
        this.y = y;
        this.z = z;
        this.w = w;
    }

    public this(Vector3f axis, float angle)
    {
        float halfSin0 = cast(float) sin(angle / 2);
        float cosHalfAngle = cast(float) cos(angle / 2);

        this.x = axis.x * halfSin0;
        this.y = axis.y * halfSin0;
        this.z = axis.z * halfSin0;
        this.w = cosHalfAngle;
    }

    public this(Quaternion quat)
    {
        this = quat;
    }

    public auto opOpAssign(string op, T)(T value) if (__traits(compiles,
            this.opBinary!(op)(value)))
    {
        return this = this.opBinary!(op)(value); //forward to real version and store it this
    }

    public auto opBinary(string op)(Quaternion quat) if (op == "-")
    {
        return Quaternion(x - quat.x, y - quat.y, z - quat.z, w - w);
    }

    public auto opBinary(string op)(Quaternion quat) if (op == "-")
    {
        return Quaternion(x - quat.x, y - quat.y, z - quat.z, w - w);
    }

    public auto opBinary(string op)(Quaternion quat) if (op == "*")
    {
        Quaternion result;
        result.w = (w * quat.w - x * quat.x - y * quat.y - z * quat.z);
        result.x = (w * quat.x + x * quat.w + y * quat.z - z * quat.y);
        result.y = (w * quat.y - x * quat.z + y * quat.w + z * quat.x);
        result.z = (w * quat.z + x * quat.y - y * quat.x + z * quat.w);
        return result;
    }

    public auto opBinary(string op)(Vector3f vector) if (op == "*")
    {
        Quaternion result;
        result.w = (-x * vector.x - y * vector.y - z * vector.z);
        result.x = (w * vector.x + y * vector.z - z * vector.y);
        result.y = (w * vector.y + z * vector.x - x * vector.z);
        result.z = (w * vector.z + x * vector.y - y * vector.x);
        return result;
    }

    public auto opBinary(string op)(float scalar) if (op == "*")
    {
        return Quaternion(x * scalar, y * scalar, z * scalar, w * scalar);
    }

    public auto opAssign(Quaternion quat)
    {
        this.x = quat.x;
        this.y = quat.y;
        this.z = quat.z;
        this.w = quat.w;
    }

    public float length()
    {
        return cast(float) sqrt(x * x + y * y + z * z + w * w);
    }

    public auto normalize()
    {
        float length = length();

        x /= length;
        y /= length;
        z /= length;
        w /= length;
    }
    
	public auto conjugate()
	{
		return Quaternion(-x, -y, -z, w);
	}

    @property public auto matrix()
    {
        normalize();
        Matrix4f matrix;
        matrix[0] = [1 - 2 * y * y - 2 * z * z, 2 * x * y + 2 * z * w, 2 * x * z - 2 * y * w,
            0];
        matrix[1] = [2 * x * y - 2 * z * w, 1 - 2 * x * x - 2 * z * z, 2 * y * z + 2 * x * w,
            0];
        matrix[2] = [2 * x * z + 2 * y * w, 2 * y * z - 2 * x * w, 1 - 2 * x * x - 2 * y * y,
            0];
        matrix[3] = [0, 0, 0, 1];
        return matrix;
    }

    @property public auto matrix(Matrix4f matrix)
    {
        float trace = matrix[0, 0] + matrix[1, 1] + matrix[2, 2];

        if (trace > 0)
        {
            float s = 0.5f / cast(float) sqrt(trace + 1.0f);
            w = 0.25f / s;
            x = (matrix[1, 2] - matrix[2, 1]) * s;
            y = (matrix[2, 0] - matrix[0, 2]) * s;
            z = (matrix[0, 1] - matrix[1, 0]) * s;
        }
        else
        {
            if (matrix[0, 0] > matrix[1, 1] && matrix[0, 0] > matrix[2, 2])
            {
                float s = 2.0f * cast(float) sqrt(1.0f + matrix[0, 0] - matrix[1, 1] - matrix[2,
                    2]);
                w = (matrix[1, 2] - matrix[2, 1]) / s;
                x = 0.25f * s;
                y = (matrix[1, 0] + matrix[0, 1]) / s;
                z = (matrix[2, 0] + matrix[0, 2]) / s;
            }
            else if (matrix[1, 1] > matrix[2, 2])
            {
                float s = 2.0f * cast(float) sqrt(1.0f + matrix[1, 1] - matrix[0, 0] - matrix[2,
                    2]);
                w = (matrix[2, 0] - matrix[0, 2]) / s;
                x = (matrix[1, 0] + matrix[0, 1]) / s;
                y = 0.25f * s;
                z = (matrix[2, 1] + matrix[1, 2]) / s;
            }
            else
            {
                float s = 2.0f * cast(float) sqrt(1.0f + matrix[2, 2] - matrix[0, 0] - matrix[1,
                    1]);
                w = (matrix[0, 1] - matrix[1, 0]) / s;
                x = (matrix[2, 0] + matrix[0, 2]) / s;
                y = (matrix[1, 2] + matrix[2, 1]) / s;
                z = 0.25f * s;
            }
        }
        normalize();
    }
}
