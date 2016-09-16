module radium.graphics.utils;

import radium.utility.error;
import radium.graphics.render.mesh;
import radium.assets.rdmesh;

class GLException : RadiumException
{
    @nogc @safe pure nothrow this(string msg, string file = __FILE__,
            size_t line = __LINE__, Throwable next = null)
    {
        super(msg, file, line, next);
    }
}

class SDLException : RadiumException
{
    this(string msg, string file = __FILE__,
            size_t line = __LINE__, Throwable next = null)
    {
        super(msg ~ getSDLError(), file, line, next);
    }
}

string getSDLError()
{
    import derelict.sdl2.sdl;
	import std.conv : to;
	
    return SDL_GetError().to!string;
}

Mesh loadRDMesh(RDMesh rmesh)
{
    import radium.math.vector;

    Mesh result = new Mesh(new Vector3f[rmesh.vertices.length],
            new Vector3f[rmesh.vertices.length], new Vector3f[rmesh.vertices.length],
            new TextureCoordinate[rmesh.vertices.length], new uint[rmesh.triangles.length * 3]);

    foreach (i, vertex; rmesh.vertices)
    {
        result.positions[i] = vertex.position;
        result.textureCoordinates[i].x = vertex.texCoordX;
        result.textureCoordinates[i].y = vertex.texCoordY;
    }
    foreach (i, triangle; rmesh.triangles)
    {
        result.indexes[i * 3] = triangle.vert1.index;
        result.indexes[i * 3 + 1] = triangle.vert2.index;
        result.indexes[i * 3 + 2] = triangle.vert3.index;
    }

    return result;
}
