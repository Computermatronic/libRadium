module radium.graphics.render.shader;

import radium.graphics.utils;
import radium.graphics.core.primatives;

import radium.math.matrix;

import derelict.opengl3.gl3;

import std.string;

class Shader : Bindable
{
    struct Uniforms
    {
        GLuint mvp;
    }

    GLuint vertexShader;
    GLuint fragmentShader;
    GLuint shaderProgram;
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
                VertexAttributeArray.textureCoordinates, "iTextureCoordinat");
        glBindAttribLocation(shaderProgram, VertexAttributeArray.normal, "iNormal");
        glLinkProgram(shaderProgram);
        GLint linkStatus;
        glGetProgramiv(shaderProgram, GL_LINK_STATUS, &linkStatus);
        if (linkStatus == GL_FALSE)
        {
            GLint length;
            string log;
            glGetProgramiv(shaderProgram, GL_INFO_LOG_LENGTH, &length);
            if (length > 0)
            {
                log = new string(length);
                glGetProgramInfoLog(shaderProgram, length, null, cast(char*) log.ptr);
            }
            glDeleteProgram(shaderProgram);
            throw new GLException("Could not link shader \n" ~ log);
        }
        uniforms.mvp = glGetUniformLocation(shaderProgram, "iMVP");
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
            string log;
            glGetShaderiv(shader, GL_INFO_LOG_LENGTH, &length);
            if (length > 0)
            {
                log = new string(length);
                glGetShaderInfoLog(shader, length, null, cast(char*) log.ptr);
            }
            glDeleteProgram(shaderProgram);
            throw new GLException("Could not compile shader \n" ~ log);
        }
        return shader;
    }

    void bind()
    {
        glUseProgram(shaderProgram);
        glEnableVertexAttribArray(VertexAttributeArray.position);
        glEnableVertexAttribArray(VertexAttributeArray.textureCoordinates);
    }

    void setUniform(T)(GLuint uniform, T* data)
    {
        static if (is(T == Matrix4f))
            glUniformMatrix4fv(uniform, 1, GL_TRUE, cast(float*) data.m_matrix.ptr);
        else
            static assert(0, "Invalid type for setUniform");
    }
}
