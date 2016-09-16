module radium.graphics.core.transform;

import radium.math;

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
        if (parent !is null)
            return parent.getMatrix() * createTranslationMatrix(
                    translation) * rotation.matrix() * createScaleMatrix(scale);
        else
            return createTranslationMatrix(translation) * rotation.matrix() * createScaleMatrix(
                    scale);
    }
}
