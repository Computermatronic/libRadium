module radium.graphics.core.primatives;

import radium.math.matrix;

enum VertexAttributeArray
{
    position = 0,
    textureCoordinates,
    normal,
    tangent
}

interface Drawable
{
    void draw(double dt, Matrix4f* mat = null);
}

interface Bindable
{
    void bind();
}

interface Projector
{
    Matrix4f getProjection();
}
