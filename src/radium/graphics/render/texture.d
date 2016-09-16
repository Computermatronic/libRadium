module radium.graphics.render.texture;

import radium.graphics.core.color;

import derelict.opengl3.gl;

class Texture
{
    Color[] pixels;
    size_t w, h;
    GLuint tex;

    this(Color[] pixels, size_t w, size_t h)
    {
        this.pixels = pixels;
        this.w = w;
        this.h = h;
        glGenTextures(1, &tex);
        glLoad();
    }

    this()
    {
        this([Color(0f, 0f, 0f, 0f), Color(1f, 1f, 1f, 1f), Color(1f, 1f, 1f,
                1f), Color(0, 0, 0, 0)], 2, 2);
    }

    void glLoad()
    {
        glBindTexture(GL_TEXTURE_2D, tex);
        glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, w, h, 0, GL_RGBA, GL_FLOAT, pixels.ptr);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_MIRRORED_REPEAT);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_MIRRORED_REPEAT);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_NEAREST);
        glGenerateMipmap(GL_TEXTURE_2D);
    }

    void bind(uint texid = GL_TEXTURE0)
    {
        glActiveTexture(texid);
        glBindTexture(GL_TEXTURE_2D, tex);
    }
}
