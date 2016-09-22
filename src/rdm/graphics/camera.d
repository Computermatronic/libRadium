module rdm.graphics.camera;

import rdm.graphics.primatives;
import rdm.graphics.transform;
import rdm.math.matrix;

class Camera : Projector
{
    Transform transform;
    Matrix4f projection;

    this(float fov, float aspectRatio, float zNear, float zFar)
    {
        projection = createPerspectiveMatrix(fov, aspectRatio, zNear, zFar);
        transform = new Transform();
    }

    Matrix4f getMatrix()
    {
        return projection * transform.getMatrix();
    }
}
