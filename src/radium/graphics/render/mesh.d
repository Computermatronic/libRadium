module radium.graphics.render.mesh;

import radium.graphics.core.primatives : VertexAttributeArray;
import radium.graphics.core.color;
import radium.math.vector;

import std.range, std.array;
import derelict.opengl3.gl3;

struct TextureCoordinate
{
    float x;
    float y;
}

class Mesh
{
    Vector3f[] positions;
    Vector3f[] normals;
    Vector3f[] tangents;

    TextureCoordinate[] textureCoordinates;
    uint[] indexes;

    uint vbo;

    this(Vector3f[] positions, Vector3f[] normals, Vector3f[] tangents,
            TextureCoordinate[] textureCoordinates, uint[] indexes)
    {
        this.positions = positions;
        this.normals = normals;
        this.tangents = tangents;

        this.textureCoordinates = textureCoordinates;
        this.indexes = indexes;

        glGenBuffers(1, &vbo);
    }

    ~this()
    {
        glDeleteBuffers(1, &vbo);
    }

    Mesh dup()
    {
        return new Mesh(positions.dup(), normals.dup(), tangents.dup(),
                textureCoordinates.dup(), indexes.dup());
    }

    void glLoad(uint graphicsMemoryMode = GL_STATIC_DRAW)
    {
        size_t positionSize = positions.length * Vector3f.sizeof;
        size_t textureCoordinatesSize = textureCoordinates.length * TextureCoordinate.sizeof;
        size_t normalSize = normals.length * Vector3f.sizeof;
        size_t bufferSize = positionSize + textureCoordinatesSize + normalSize;
        size_t indexSize = indexes.length * uint.sizeof;

        glBindBuffer(GL_ARRAY_BUFFER, vbo);

        glBufferData(GL_ARRAY_BUFFER, bufferSize, null, graphicsMemoryMode);

        glBufferSubData(GL_ARRAY_BUFFER, 0, positionSize, positions.ptr);
        glBufferSubData(GL_ARRAY_BUFFER, positionSize, textureCoordinatesSize,
                textureCoordinates.ptr);
        glBufferSubData(GL_ARRAY_BUFFER, positionSize + textureCoordinatesSize,
                normalSize, normals.ptr);

        glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, vbo);
        glBufferData(GL_ELEMENT_ARRAY_BUFFER, indexSize,
                cast(void*) indexes.ptr, graphicsMemoryMode);
        glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, 0);
    }

    void draw(uint drawMode = GL_TRIANGLE_STRIP)
    {
        size_t positionSize = positions.length * Vector3f.sizeof;
        size_t textureCoordinatesSize = textureCoordinates.length * TextureCoordinate.sizeof;
        size_t bufferSize = positionSize + textureCoordinatesSize;

        glBindBuffer(GL_ARRAY_BUFFER, vbo);
        glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, vbo);

        glVertexAttribPointer(VertexAttributeArray.position, 3, GL_FLOAT, GL_FALSE, 0, null);

        glVertexAttribPointer(VertexAttributeArray.textureCoordinates, 2,
                GL_FLOAT, GL_FALSE, 0, cast(void*) positionSize);

        glVertexAttribPointer(VertexAttributeArray.normal, 3, GL_FLOAT,
                GL_FALSE, 0, cast(void*) positionSize + textureCoordinatesSize);

        glDrawArrays(drawMode, 0, 3);
    }
}
