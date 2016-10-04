module rdm.graphics.gltexture;

import derelict.opengl3.gl3;

struct GLTexture
{
    uint tbo;

    this(uint[] pixels, size_t width, size_t height)
    {
        glGenTextures(1, &tbo);
        glBindTexture(GL_TEXTURE_2D, tbo);
        glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, width, height, 0, GL_RGBA,
                GL_UNSIGNED_BYTE, pixels.ptr);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_MIRRORED_REPEAT);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_MIRRORED_REPEAT);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_NEAREST);
        glGenerateMipmap(GL_TEXTURE_2D);
    }

    void bind(uint texid = GL_TEXTURE0)
    {
        glActiveTexture(texid);
        glBindTexture(GL_TEXTURE_2D, tbo);
    }
}
