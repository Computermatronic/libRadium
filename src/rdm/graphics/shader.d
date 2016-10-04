module rdm.graphics.shader;

import std.string : toStringz;

import derelict.opengl3.gl3;

import rdm.graphics.errors;
import rdm.graphics.primatives;
import rdm.math.matrix;

class Shader
{
    struct Uniforms
    {
        GLuint mvp;
        GLuint tex1;
    }

    uint vertexShader, fragmentShader, shaderProgram;

    Uniforms uniforms;

    this(string vertexSrc, string fragmentSrc)
    {
        shaderProgram = glCreateProgram();

        vertexShader = compileShader(vertexSrc, GL_VERTEX_SHADER);
        fragmentShader = compileShader(fragmentSrc, GL_FRAGMENT_SHADER);

        glAttachShader(shaderProgram, vertexShader);
        glAttachShader(shaderProgram, fragmentShader);

        glBindAttribLocation(shaderProgram, VertexAttributeArray.position, "iPosition");
        glBindAttribLocation(shaderProgram,
                VertexAttributeArray.textureCoordinate, "iTextureCoordinate");
        glBindAttribLocation(shaderProgram, VertexAttributeArray.normal, "iNormal");
        glLinkProgram(shaderProgram);
        GLint linkStatus;
        glGetProgramiv(shaderProgram, GL_LINK_STATUS, &linkStatus);
        if (linkStatus == GL_FALSE)
        {
            GLint length;
            char[] log;
            glGetProgramiv(shaderProgram, GL_INFO_LOG_LENGTH, &length);
            if (length > 0)
            {
                log = new char[](length);
                glGetProgramInfoLog(shaderProgram, length, null, cast(char*) log.ptr);
            }
            glDeleteProgram(shaderProgram);
            throw new GLException("Could not link shader \n" ~ cast(string) log);
        }
        uniforms.mvp = glGetUniformLocation(shaderProgram, "iMVP");
        uniforms.tex1 = glGetUniformLocation(shaderProgram, "iTexture1");
    }

    GLuint compileShader(string src, GLenum type)
    {

        GLint compileStatus;
        GLuint shader = glCreateShader(type);
        glShaderSource(shader, 1, [cast(char*) src.toStringz()].ptr, [cast(GLint) src.length].ptr);
        glCompileShader(shader);
        glGetShaderiv(shader, GL_COMPILE_STATUS, &compileStatus);
        if (compileStatus == GL_FALSE)
        {
            GLint length;
            char[] log;
            glGetShaderiv(shader, GL_INFO_LOG_LENGTH, &length);
            if (length > 0)
            {
                log = new char[](length);
                glGetShaderInfoLog(shader, length, null, cast(char*) log.ptr);
            }
            glDeleteProgram(shaderProgram);
            throw new GLException("Could not compile shader \n" ~ cast(string) log);
        }
        return shader;
    }

    void bind()
    {
        glUseProgram(shaderProgram);
    }

    void setUniform(T)(GLuint uniform, T data)
    {
        static if (is(T == Matrix4f))
            glUniformMatrix4fv(uniform, 1, GL_TRUE, cast(float*) data.m_matrix.ptr);
        else static if (is(T == Texture))
            glUniform1i(uniform, data.tex);
        else
            static assert(0, "Invalid type for setUniform");
    }
}
