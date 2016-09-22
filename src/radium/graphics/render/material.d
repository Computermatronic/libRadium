module radium.graphics.render.material;

import radium.graphics.core.primatives;
import radium.graphics.render.shader;
import radium.graphics.render.texture;

class Material : Bindable
{
    Shader shader;
    Texture texture;

    this(Shader shader, Texture texture)
    {
        this.shader = shader;
        this.texture = texture;
    }

    void bind()
    {
        shader.bind();
        if (texture)
            texture.bind();
    }
}
