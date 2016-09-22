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
    uint[] indices;

    uint vbo, ibo;

    this(Vector3f[] positions, Vector3f[] normals, Vector3f[] tangents,
            TextureCoordinate[] textureCoordinates, uint[] indices)
    {
        this.positions = positions;
        this.normals = normals;
        this.tangents = tangents;

        this.textureCoordinates = textureCoordinates;
        this.indices = indices;

        glGenBuffers(1, &vbo);
        glGenBuffers(1, &ibo);
    }

    ~this()
    {
        glDeleteBuffers(1, &vbo);
        glDeleteBuffers(1, &ibo);
    }

    Mesh dup()
    {
        return new Mesh(positions.dup(), normals.dup(), tangents.dup(),
                textureCoordinates.dup(), indices.dup());
    }

    void glLoad(uint graphicsMemoryMode = GL_STATIC_DRAW)
    {
        size_t positionSize = positions.length * Vector3f.sizeof;
        size_t textureCoordinatesSize = textureCoordinates.length * TextureCoordinate.sizeof;
        size_t normalSize = normals.length * Vector3f.sizeof;
        size_t bufferSize = positionSize + textureCoordinatesSize + normalSize;
        size_t indexSize = indices.length * uint.sizeof;

        glBindBuffer(GL_ARRAY_BUFFER, vbo);

        glBufferData(GL_ARRAY_BUFFER, bufferSize, null, graphicsMemoryMode);

        glBufferSubData(GL_ARRAY_BUFFER, 0, positionSize, positions.ptr);
        glBufferSubData(GL_ARRAY_BUFFER, positionSize, textureCoordinatesSize,
                textureCoordinates.ptr);
        glBufferSubData(GL_ARRAY_BUFFER, positionSize + textureCoordinatesSize,
                normalSize, normals.ptr);

        glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, ibo);
        glBufferData(GL_ELEMENT_ARRAY_BUFFER, indexSize,
                cast(void*) indices.ptr, graphicsMemoryMode);
        glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, 0);
    }

    void draw(uint drawMode = GL_TRIANGLES)
    {
        size_t positionSize = positions.length * Vector3f.sizeof;
        size_t textureCoordinatesSize = textureCoordinates.length * TextureCoordinate.sizeof;
        size_t bufferSize = positionSize + textureCoordinatesSize;
		
        glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, ibo);
        glBindBuffer(GL_ARRAY_BUFFER, vbo);

        glVertexAttribPointer(VertexAttributeArray.position, 3, GL_FLOAT, GL_FALSE, 0, null);

        glVertexAttribPointer(VertexAttributeArray.textureCoordinates, 2,
                GL_FLOAT, GL_FALSE, 0, cast(void*) positionSize);

        glVertexAttribPointer(VertexAttributeArray.normal, 3, GL_FLOAT,
                GL_FALSE, 0, cast(void*) positionSize + textureCoordinatesSize);
		glDrawElements(drawMode,indices.length, GL_UNSIGNED_INT, null);
//        glDrawArrays(drawMode, 0, 3);
    }
}