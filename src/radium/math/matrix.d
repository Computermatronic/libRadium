module radium.math.matrix;

import radium.math.vector;
import radium.math.utils;

import std.math;
import std.traits;
import std.meta;

alias Matrix4f = Matrix!(4, float);

public Matrix4f createPerspectiveMatrix(float fov, float aspectRatio, float zNear, float zFar)
{
    Matrix4f matrix;
    float ar = aspectRatio;
    float tanHalfFOV = cast(float) tan(fov / 2);
    float zRange = zNear - zFar;

    matrix[0] = [1.0f / (tanHalfFOV * ar), 0, 0, 0];
    matrix[1] = [0, 1.0f / tanHalfFOV, 0, 0];
    matrix[2] = [0, 0, (-zNear - zFar) / zRange, 2 * zFar * zNear / zRange];
    matrix[3] = [0, 0, 1, 0];

    return matrix;
}

public Matrix4f createOrthographicMatrix(float left, float right, float top,
        float bottom, float zNear, float zFar)
{
    Matrix4f matrix;
    float width = (right - left);
    float height = (top - bottom);
    float depth = (zFar - zNear);

    matrix[0] = [2 / width, 0, 0, 0];
    matrix[1] = [0, 2 / height, 0, 0];
    matrix[2] = [0, 0, -2 / depth, 0];
    matrix[3] = [-(right + left) / width, -(top + bottom) / height, -(zFar + zNear) / depth, 1];

    return matrix;
}

public auto createTranslationMatrix(Vector3f trans)
{
    Matrix4f translationMatrix;

    translationMatrix[0] = [1, 0, 0, trans.x];
    translationMatrix[1] = [0, 1, 0, trans.y];
    translationMatrix[2] = [0, 0, 1, trans.z];
    translationMatrix[3] = [0, 0, 0, 1];

    return translationMatrix;
}

public auto createRotationMatrix(Vector3f rotation)
{
    auto cos0x = cos(rotation.x);
    auto sin0x = sin(rotation.x);
    auto cos0y = cos(rotation.y);
    auto sin0y = sin(rotation.y);
    auto cos0z = cos(rotation.z);
    auto sin0z = sin(rotation.z);
    Matrix4f xMatrix, yMatrix, zMatrix;

    xMatrix[0] = [1, 0, 0, 0];
    xMatrix[1] = [0, cos0x, -sin0x, 0];
    xMatrix[2] = [0, sin0x, cos0x, 0];
    xMatrix[3] = [0, 0, 0, 1];

    yMatrix[0] = [cos0y, 0, sin0y, 0];
    yMatrix[1] = [0, 1, 0, 0];
    yMatrix[2] = [-sin0y, 0, cos0y, 0];
    yMatrix[3] = [0, 0, 0, 1];

    zMatrix[0] = [cos0z, -sin0z, 0, 0];
    zMatrix[1] = [sin0z, cos0z, 0, 0];
    zMatrix[2] = [0, 0, 1, 0];
    zMatrix[3] = [0, 0, 0, 1];

    return (zMatrix * yMatrix * xMatrix);
}

public auto createScaleMatrix(Vector3f factor)
{
    Matrix4f scaleMatrix;
    scaleMatrix[0] = [factor.x, 0, 0, 0];
    scaleMatrix[1] = [0, factor.y, 0, 0];
    scaleMatrix[2] = [0, 0, factor.z, 0];
    scaleMatrix[3] = [0, 0, 0, 1];
    return scaleMatrix;
}

//extracts angles radians from the matrix's rotation
//this might be wierd cause of gimbal lock or somthing.

public Vector3f eulerAngles(ref Matrix4f matrix)
{
    Vector3f result;
    result[0] = atan2(-matrix[1, 2], matrix[2, 2]);
    float cosYangle = sqrt(pow(matrix[0, 0], 2) + pow(matrix[0, 1], 2));
    result[1] = atan2(matrix[0, 2], cosYangle);
    float sinXangle = sin(result[0]);
    float cosXangle = cos(result[0]);
    result[2] = atan2(cosXangle * matrix[1][0] + sinXangle * matrix[2][0],
            cosXangle * matrix[1, 1] + sinXangle * matrix[2, 1]);
    return result;
}

//Remember that these matricies are ROW MAJOR!
//OpenGL is COLOUM MAJOR!
//when sending these matricies to the gpu set transpose to GL_TRUE.
struct Matrix(size_t Size, Type)
{
    alias Matrix_t = Matrix!(Size, Type);

    Type[Size][Size] m_matrix;

    this(Matrix_t matrix)
    {
        this.m_matrix = matrix.m_matrix;
    }

    this(T...)(T matrix) if (T.length == Size * Size && allSatisfy!(isMatrixType, T))
    {
        foreach (i; Iota!(0u, T.length))
        {
            //Use of the Iota template makes the compiler unroll this loop at compile time.
            this[cast(int) floor(cast(real) i / Size), i % Size] = matrix[i];
        }
    }

    this(Type[Size][Size] matrix)
    {
        this.m_matrix = matrix;
    }

    this(Type[Size * Size] matrix)
    {
        foreach (i; Iota!(0u, Size * Size))
        {
            this[cast(int) floor(cast(real) i / Size), i % Size] = matrix[i];
        }
    }

    this(Type[][] matrix)
    {
        enforce!MathException(matrix.length == Size, "array length incorrect length for assignment to matrix");
        foreach (i; Iota!(0u, Size))
        {
            enforce!MathException(matrix[i].length == Size,
                    "array length incorrect length for assignment to matrix");
            foreach (j; Iota!(0u, Size))
                this[i, j] = matrix[i][j];
        }
    }

    this(Type[] matrix)
    {
        enforce!MathException(matrix.length == Size * Size,
                "array length incorrect length for assignment to matrix");
        foreach (i, element; Iota!(0u, Size * Size))
        {
            this[cast(int) floor(cast(real) i / Size), i % Size] = element;
        }
    }

    auto opOpAssign(string op, T)(T value)
            if (__traits(compiles, this.opBinary!(op)(value)))
    {
        auto result = this.opBinary!(op)(value); //forward to real version and store it this
        return this = result;
    }

    auto opBinary(string op)(Matrix_t matrix) if (op == "+")
    {
        Matrix_t result;
        foreach (i; Iota!(0u, Size))
        {
            foreach (j; Iota!(0u, Size))
            {
                result[i, j] = this[i, j] + matrix[i, j];
            }
        }
        return result;
    }

    auto opBinary(string op)(Matrix_t matrix) if (op == "-")
    {
        Matrix_t result;
        foreach (i; ota!(0u, Size))
        {
            foreach (j; Iota!(0u, Size))
            {
                result[i, j] = this[i, j] - matrix[i, j];
            }
        }
        return result;
    }

    auto opBinary(string op)(Matrix_t matrix) if (op == "*")
    {
        Matrix_t result;
        Type sumProduct;

        foreach (i; Iota!(0u, Size))
        {
            foreach (j; Iota!(0u, Size))
            {
                sumProduct = 0;
                foreach (k; Iota!(0u, Size))
                {
                    sumProduct += this[i, k] * matrix[k, j];
                }
                result[i, j] = sumProduct;
            }
        }
        return result;
    }

    auto opBinary(string op)(Type scalar) if (op == "+")
    {
        Matrix_t result;
        foreach (i; Iota!(0u, Size))
        {
            foreach (j; Iota!(0u, Size))
            {
                this[i, j] = result[i, j] + scalar;
            }
        }
        return result;
    }

    auto opBinary(string op)(Type scalar) if (op == "-")
    {
        Matrix_t result;
        foreach (i; ota!(0u, Size))
        {
            foreach (j; Iota!(0u, Size))
            {
                result[i, j] = this[i, j] - scalar;
            }
        }
        return result;
    }

    auto opBinary(string op)(Type scalar) if (op == "*")
    {
        Matrix_t result;
        foreach (i; Iota!(0u, Size))
        {
            foreach (j; Iota!(0u, Size))
            {
                result[i, j] = this[i, j] * scalar;
            }
        }
        return result;
    }

    auto opBinary(string op)(Vector!(Size - 1, Type) vector) if (op == "*")
    {
        Type sumProduct;
        Matrix_t result;
        foreach (i; Iota!(0u, Size))
        {
            foreach (j; Iota!(0u, Size))
            {
                sumProduct = 0;
                foreach (k; Iota!(0u, Size - 1))
                    sumProduct += this[i, j] * vector[k];
                result[i, j] = sumProduct;
            }
        }
        return result;
    }

    auto opBinary(string op)(Vector!(Size, Type) vector) if (op == "*")
    {
        Type sumProduct;
        Matrix_t result;
        foreach (i; Iota!(0u, Size))
        {
            foreach (j; Iota!(0u, Size))
            {
                sumProduct = 0;
                foreach (k; Iota!(0u, Size))
                    sumProduct += this[i, j] * vector[j];
                result[i, j] = sumProduct;
            }
        }
        return result;
    }

    auto opIndex(size_t row, size_t col) const
    {
        return this.m_matrix[row][col];
    }

    auto opIndexAssign(Type assign, size_t row, size_t col)
    {
        return this.m_matrix[row][col] = assign;
    }

    auto opIndex(size_t row) const
    {
        return this.m_matrix[row];
    }

    auto opIndexAssign(Type[Size] assign, size_t row)
    {
        return this.m_matrix[row] = assign;
    }

    auto opIndexAssign(Type[] assign, size_t row)
    {
        enforce!MathException(Size == assign.length, "row length incorrect length for assignment to matrix");
        foreach (i; Iota!(0u, Size))
            this[row, i] = row;
    }

    auto opAssign(Matrix_t matrix)
    {
        this.m_matrix = matrix.m_matrix;
    }

    @property static auto identity(float n = 1.0f)
    {
        Matrix_t matrix;
        foreach (i; Iota!(0u, Size))
            foreach (j; Iota!(0u, Size))
                if (i == j)
                    matrix[i, j] = n;
                else
                    matrix[i, j] = 0;
        return matrix;
    }

    auto transpose()
    {
        auto result = Matrix_t();
        foreach (i; Iota!(0u, Size))
            foreach (j; Iota!(0u, Size))
                result[j, i] = this[i, j];
        this = result;
    }

    Type determinant(size_t N = Size) const
    {

        int i, j, k, x = 0, y = 0;
        Matrix_t b;
        Type det = 0, flg = 1;

        if (N == 1)
        {
            return this[0, 0];
        }
        else
        {
            det = 0;
            for (k = 0; k < N; k++)
            {

                for (i = 0; i < N; i++)
                    for (j = 0; j < N; j++)
                    {
                        b[i, j] = 0;
                        if ((i != 0) && (j != k))
                        {

                            b[x, y] = this[i, j];

                            if (y < (N - 2))
                            {
                                y++;
                            }
                            else
                            {
                                y = 0;
                                x++;
                            }
                        }
                    }

                det += (flg * (this[0, k] * b.determinant(N - 1)));

                flg *= -1;
                y = 0;
                x = 0;

            }
        }
        return det;

    }

    auto inverted() const
    {
        int i, j, p, q, x = 0, y = 0;
        Matrix_t c, inv;
        Type dt;
        dt = determinant(Size);
        for (p = 0; p < Size; p++)
            for (q = 0; q < Size; q++)
            {
                for (i = 0; i < Size; i++)
                    for (j = 0; j < Size; j++)
                    {
                        c[i, j] = 0;
                        if ((i != p) && (j != q))
                        {
                            c[x, y] = this[i, j];

                            if (y < (Size - 2))
                            {
                                y++;
                            }
                            else
                            {
                                y = 0;
                                x++;
                            }
                        }
                    }

                inv[q, p] = ((c.determinant(Size - 1)) * pow(-1, (p + q)));
                x = 0;
                y = 0;
            }

        for (i = 0; i < Size; i++)
        {
            for (j = 0; j < Size; j++)
            {
                inv[i, j] = (inv[i, j] / dt);
            }
        }
        return inv;
    }

    string toString() const
    {
        import std.conv : to;
        import std.array;
        import std.stdio;

        Appender!string result;
        string[Size][Size] stringMatrix;
        uint longest;
        foreach (i; Iota!(0u, Size))
        {
            foreach (j; Iota!(0u, Size))
            {
                stringMatrix[i][j] = to!string(this[i, j]);
                longest = stringMatrix[i][j].length > longest ? stringMatrix[i][j].length : longest;
            }
        }
        foreach (i; Iota!(0u, Size))
        {
            foreach (j; Iota!(0u, Size))
            {
                result ~= stringMatrix[i][j] ~ replicate(" ",
                        longest - stringMatrix[i][j].length) ~ (j >= Size - 1 ? "" : ",");
            }
            result ~= '\n';
        }
        return result.data;
    }

    enum isMatrixType(T) = isImplicitlyConvertible!(T, Type);
}

enum isMatrix(T) = isInstanceOf!(Matrix, T); //This fixes a wierd bug
