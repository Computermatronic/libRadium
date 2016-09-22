module rdm.asset.rdmesh;

import std.exception : enforce;

import rdm.stream.core : InputStream, readAs;
import rdm.math.vector;

public enum uint RDMeshMagicNumber = 0x3DF11E00;

public enum RDMeshVersion : uint
{
    RDM100 = 1
}

public struct RDMeshTriangle
{
    RDMesh mesh;
    uint index;

    @property RDMeshVertex vert1()
    {
        return mesh.vertices[mesh._triangles[index].vertId1];
    }

    @property RDMeshVertex vert2()
    {
        return mesh.vertices[mesh._triangles[index].vertId2];
    }

    @property RDMeshVertex vert3()
    {
        return mesh.vertices[mesh._triangles[index].vertId3];
    }
}

public struct RDMeshVertex
{
    RDMesh mesh;
    size_t index;

    @property Vector3f position()
    {
        return mesh._vertices[index].position;
    }

    @property float texCoordX()
    {
        return mesh._vertices[index].texCoordX;
    }

    @property float texCoordY()
    {
        return mesh._vertices[index].texCoordY;
    }

    @property RDMeshTriangle tri1()
    {
        return mesh.triangles[mesh._vertices[index].triId1];
    }

    @property RDMeshTriangle tri2()
    {
        return mesh.triangles[mesh._vertices[index].triId2];
    }

    @property RDMeshTriangle tri3()
    {
        return mesh.triangles[mesh._vertices[index].triId3];
    }
}

class RDMesh
{
    private RDMeshTriangleData[] _triangles;
    private RDMeshVertexData[] _vertices;

    this(InputStream stream)
    {
        auto meshHeader = stream.readAs!RDMeshHeader();
        enforce!RDMeshException(meshHeader.magicNumber == RDMeshMagicNumber, "File is not RDMesh!");
        enforce!RDMeshException(meshHeader.meshVersion == RDMeshVersion.RDM100,
                "RDMesh version not supported!");
        _vertices = stream.readAs!RDMeshVertexData(meshHeader.vertexCount);
        _triangles = stream.readAs!RDMeshTriangleData(meshHeader.triangleCount);
    }

    @property auto triangles()
    {
        struct Result
        {
            RDMesh mesh;
            size_t offset;

            @property size_t length()
            {
                return mesh._triangles.length - offset;
            }

            RDMeshTriangle opIndex(size_t index)
            {
                return RDMeshTriangle(mesh, index + offset);
            }

            int opApply(int delegate(RDMeshTriangle) dg)
            {
                int result;
                for (size_t i; i < mesh._triangles.length; i++)
                {
                    if ((result = dg(opIndex(i))) != 0)
                        return result;
                }
                return result;
            }

            int opApply(int delegate(size_t, RDMeshTriangle) dg)
            {
                int result;
                for (size_t i; i < mesh._triangles.length; i++)
                {
                    if ((result = dg(i, opIndex(i))) != 0)
                        return result;
                }
                return result;
            }
        }

        return Result(this, 0);
    }

    @property auto vertices()
    {
        struct Result
        {
            RDMesh mesh;
            size_t offset;

            @property size_t length()
            {
                return mesh._vertices.length - offset;
            }

            RDMeshVertex opIndex(size_t index)
            {
                return RDMeshVertex(mesh, index + offset);
            }

            int opApply(int delegate(RDMeshVertex) dg)
            {
                int result;
                for (size_t i; i < mesh._vertices.length; i++)
                {
                    if ((result = dg(opIndex(i))) != 0)
                        return result;
                }
                return result;
            }

            int opApply(int delegate(size_t, RDMeshVertex) dg)
            {
                int result;
                for (size_t i; i < mesh._vertices.length; i++)
                {
                    if ((result = dg(i, opIndex(i))) != 0)
                        return result;
                }
                return result;
            }
        }

        return Result(this, 0);
    }
}

private struct RDMeshHeader
{
    uint magicNumber = RDMeshMagicNumber;
    uint meshVersion = RDMeshVersion.RDM100;
    uint vertexCount;
    uint triangleCount;
}

private struct RDMeshVertexData
{
    Vector3f position;
    Vector3f normal;
    float texCoordX, texCoordY;
    uint triId1, triId2, triId3;
}

private struct RDMeshTriangleData
{
    uint vertId1, vertId2, vertId3;
}

class RDMeshException : Exception
{
    @nogc @safe pure nothrow this(string msg, string file = __FILE__,
            size_t line = __LINE__, Throwable next = null)
    {
        super(msg, file, line, next);
    }
}
