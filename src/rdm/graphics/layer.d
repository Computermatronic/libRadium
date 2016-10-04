module rdm.graphics.layer;

import derelict.opengl3.gl3;

import rdm.graphics.primatives;
import rdm.graphics.display;
import rdm.graphics.shader;
import rdm.utility.container : UnorderdSet;

class Layer3D : Drawable
{
    UnorderdSet!Drawable3D drawables;
    Projector camera;
    Shader shader;

    void draw(double delta)
    {
        auto cameraMatrix = camera.getMatrix();
        shader.bind();
        foreach (drawable; drawables)
        {
            shader.setUniform(shader.uniforms.mvp, cameraMatrix * drawable.transform.getMatrix());
            drawable.draw(delta);
        }
    }
}

class Layer : Drawable
{
    UnorderdSet!Drawable drawables;
    Shader shader;

    void draw(double delta)
    {
        shader.bind();
        foreach (drawable; drawables)
            drawable.draw(delta);
    }
}
