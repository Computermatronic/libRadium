module rdm.graphics.glmesh;

import derelict.opengl3.gl3;

import rdm.math.vector;
import rdm.graphics.primatives : VertexAttributeArray;

struct TextureCoordinate
{
    float x, y;
}

struct GLMesh
{
    uint vbo, ibo, primative = GL_TRIANGLE_STRIP;
    size_t indiceCount;

    size_t positionSize;
    size_t normalSize;
    size_t tangentSize;
    size_t textureCoordinateSize;

    this(Vector3f[] positions, Vector3f[] normals, Vector3f[] tangents,
            TextureCoordinate[] textureCoordinates, uint[] indices)
    {
        positionSize = typeof(positions).sizeof * positions.length;
        normalSize = typeof(normals).sizeof * normals.length;
        tangentSize = typeof(tangents).sizeof * tangents.length;
        textureCoordinateSize = typeof(textureCoordinates).sizeof * textureCoordinates.length;

        glGenBuffers(1, &vbo);
        glBindBuffer(vbo, GL_ARRAY_BUFFER);
        glBufferData(GL_ARRAY_BUFFER,
                positionSize + normalSize + tangentSize + textureCoordinateSize,
                null, GL_STATIC_DRAW);
        glBufferSubData(GL_ARRAY_BUFFER, 0, positionSize, positions.ptr);
        glBufferSubData(GL_ARRAY_BUFFER, positionSize, normalSize, normals.ptr);
        glBufferSubData(GL_ARRAY_BUFFER, positionSize + normalSize, tangentSize, tangents.ptr);
        glBufferSubData(GL_ARRAY_BUFFER, positionSize + normalSize + tangentSize,
                textureCoordinateSize, textureCoordinates.ptr);
        glBindBuffer(0, GL_ARRAY_BUFFER);

        indiceCount = indices.length;
        size_t indiceSize = typeof(indices).sizeof * indices.length;

        glGenBuffers(1, &ibo);
        glBindBuffer(ibo, GL_ELEMENT_ARRAY_BUFFER);
        glBufferData(GL_ELEMENT_ARRAY_BUFFER, indiceSize, indices.ptr, GL_STATIC_DRAW);
        glBindBuffer(0, GL_ELEMENT_ARRAY_BUFFER);
    }

    ~this()
    {
        glDeleteBuffers(1, &vbo);
        glDeleteBuffers(1, &ibo);
    }

    void draw()
    {
    	import std.stdio;
        glBindBuffer(ibo, GL_ELEMENT_ARRAY_BUFFER);
        glBindBuffer(vbo, GL_ARRAY_BUFFER);

        glVertexAttribPointer(VertexAttributeArray.position, 3, GL_FLOAT, GL_FALSE, 0, null);
        glVertexAttribPointer(VertexAttributeArray.normal, 3, GL_FLOAT,
                GL_FALSE, 0, cast(void*)(positionSize));
        glVertexAttribPointer(VertexAttributeArray.tangent, 3, GL_FLOAT,
                GL_FALSE, 0, cast(void*)(positionSize + normalSize));
        glVertexAttribPointer(VertexAttributeArray.tangent, 3, GL_FLOAT,
                GL_FALSE, 0, cast(void*)(positionSize + normalSize + tangentSize));
        glVertexAttribPointer(VertexAttributeArray.textureCoordinate, 3, GL_FLOAT,
                GL_FALSE, 0, cast(void*)(positionSize + normalSize + tangentSize));

        glDrawElements(primative, indiceCount, GL_UNSIGNED_INT, null);
    }
}
