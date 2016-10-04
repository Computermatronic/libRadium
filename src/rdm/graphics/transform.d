module rdm.graphics.transform;

import rdm.math.quaternion;
import rdm.math.vector;
import rdm.math.matrix;

class Transform
{
    Transform parent;
    Quaternion rotation;
    Vector3f translation;
    Vector3f scale = Vector3f(1, 1, 1);

    this(Transform parent = null)
    {
        this.parent = parent;
    }

    Matrix4f getMatrix()
    {
        Matrix4f mat = Matrix4f.identity;
        if (parent !is null)
            mat *= parent.getMatrix();
        return mat * createScaleMatrix(scale) * rotation.matrix() * createTranslationMatrix(
                translation);
    }
}
