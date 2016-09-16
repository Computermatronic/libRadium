module radium.graphics.core.camera;

import radium.graphics.core.primatives;
import radium.graphics.core.transform;
import radium.math.matrix;

class Camera : Projector
{
    Transform transform;
    Matrix4f projection;

    this(float fov, float aspectRatio, float zNear, float zFar)
    {
        projection = createPerspectiveMatrix(fov, aspectRatio, zNear, zFar);
        transform = new Transform();
    }

    Matrix4f getProjection()
    {
        return projection * transform.getMatrix();
    }
}