module rdm.graphics.primatives;

interface Drawable
{
    void draw(double delta);
}

interface Projector
{
    import rdm.math.matrix : Matrix4f;

    Matrix4f getMatrix();
}

abstract class Drawable3D : Drawable
{
    import rdm.graphics.transform;

    Transform transform;

    this()
    {
        transform = new Transform();
    }
}

enum VertexAttributeArray : uint
{
    position = 0,
    normal,
    tangent,
    textureCoordinate,
}
