module rdm.graphics.glmesh;

import derelict.opengl3.gl3;

import rdm.math.vector;
import rdm.graphics.primatives : VertexAttributeArray;
import rdm.asset.rdmesh;

struct TextureCoordinate
{
    float x, y;
}

struct GLMesh
{
    uint vbo, ibo, primative = GL_TRIANGLES;
    size_t indiceCount;

    size_t positionSize;
    size_t normalSize;
    size_t tangentSize;
    size_t textureCoordinateSize;

    this(RDMesh rMesh)
    {
        auto positions = new Vector3f[rMesh.vertices.length];
        auto normals = new Vector3f[rMesh.vertices.length];
        auto tangents = new Vector3f[rMesh.vertices.length];
        auto textureCoordinates = new TextureCoordinate[rMesh.vertices.length];
        auto indices = new uint[rMesh.triangles.length * 3];

        foreach (i, vertex; rMesh.vertices)
        {
            positions[i] = vertex.position;
            textureCoordinates[i].x = vertex.texCoordX;
            textureCoordinates[i].y = vertex.texCoordY;
        }

        foreach (i, triangle; rMesh.triangles)
        {
            indices[i * 3] = triangle.vert1.index;
            indices[i * 3 + 1] = triangle.vert2.index;
            indices[i * 3 + 2] = triangle.vert3.index;
        }

        this(positions, normals, tangents, textureCoordinates, indices);
    }

    this(Vector3f[] positions, Vector3f[] normals, Vector3f[] tangents,
            TextureCoordinate[] textureCoordinates, uint[] indices)
    {
        import rdm.utility.meta : ArrayElementType;

        positionSize = ArrayElementType!(typeof(positions)).sizeof * positions.length;
        normalSize = ArrayElementType!(typeof(normals)).sizeof * normals.length;
        tangentSize = ArrayElementType!(typeof(tangents)).sizeof * tangents.length;
        textureCoordinateSize = ArrayElementType!(typeof(textureCoordinates)).sizeof
            * textureCoordinates.length;

        glGenBuffers(1, &vbo);
        glBindBuffer(GL_ARRAY_BUFFER, vbo);
        glBufferData(GL_ARRAY_BUFFER,
                positionSize + normalSize + tangentSize + textureCoordinateSize,
                null, GL_STATIC_DRAW);
        glBufferSubData(GL_ARRAY_BUFFER, 0, positionSize, positions.ptr);
        glBufferSubData(GL_ARRAY_BUFFER, positionSize, normalSize, normals.ptr);
        glBufferSubData(GL_ARRAY_BUFFER, positionSize + normalSize, tangentSize, tangents.ptr);
        glBufferSubData(GL_ARRAY_BUFFER, positionSize + normalSize + tangentSize,
                textureCoordinateSize, textureCoordinates.ptr);

        indiceCount = indices.length;
        size_t indiceSize = ArrayElementType!(typeof(indices)).sizeof * indices.length;

        glGenBuffers(1, &ibo);
        glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, ibo);
        glBufferData(GL_ELEMENT_ARRAY_BUFFER, indiceSize, indices.ptr, GL_STATIC_DRAW);
    }

    void draw()
    {
        glEnableVertexAttribArray(VertexAttributeArray.position);
        glEnableVertexAttribArray(VertexAttributeArray.normal);
        glEnableVertexAttribArray(VertexAttributeArray.tangent);
        glEnableVertexAttribArray(VertexAttributeArray.textureCoordinate);

        glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, ibo);
        glBindBuffer(GL_ARRAY_BUFFER, vbo);

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
