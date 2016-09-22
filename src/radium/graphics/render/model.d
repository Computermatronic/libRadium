module radium.graphics.render.model;

import radium.graphics.core.primatives;
import radium.graphics.core.transform;
import radium.graphics.render.mesh;
import radium.graphics.render.material;

import radium.math.matrix;

class Model : Drawable
{
    Transform transform;
    Mesh mesh;
    Material material;
    bool wiremesh = false;

    this(Mesh mesh, Material material)
    {
        this(new Transform(), mesh, material);
    }

    this(Transform transform, Mesh mesh, Material material)
    {
        this.transform = transform;
        this.mesh = mesh;
        this.material = material;
        glLoad();
    }
    
    void glLoad()
    {
        mesh.glLoad();
    }

    void draw(double dt, Matrix4f* mat = null)
    {
        Matrix4f mvp;
        if (mat !is null)
            mvp = *mat * transform.getMatrix();
        else
            mvp = transform.getMatrix();
        material.shader.setUniform(material.shader.uniforms.mvp, &mvp);
        material.bind();
        mesh.draw();
    }
}
