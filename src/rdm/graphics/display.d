module rdm.graphics.display;

import std.string : toStringz, fromStringz;
import std.exception : enforce;

import derelict.sdl2.sdl;
import derelict.opengl3.gl3;

import rdm.graphics.primatives;
import rdm.graphics.errors;
import rdm.utility.container : UnorderdSet;

class Display
{
    SDL_Window* sdl_window;
    SDL_GLContext sdl_glcontext;

    UnorderdSet!Drawable drawables;

    this(string title, size_t width, size_t height, uint flags = 0)
    {
        DerelictSDL2.load();
        DerelictGL3.load();

        enforce!SDLException(SDL_Init(SDL_INIT_EVERYTHING) == 0, SDL_GetError().fromStringz());

        sdl_window = enforce!SDLException(SDL_CreateWindow(title.toStringz,
                SDL_WINDOWPOS_CENTERED, SDL_WINDOWPOS_CENTERED,
                width, height, SDL_WINDOW_OPENGL | flags), SDL_GetError().fromStringz);

        SDL_GL_SetAttribute(SDL_GL_CONTEXT_MAJOR_VERSION, 3);
        SDL_GL_SetAttribute(SDL_GL_CONTEXT_MINOR_VERSION, 0);
        SDL_GL_SetAttribute(SDL_GL_DOUBLEBUFFER, 1);
        SDL_GL_SetAttribute(SDL_GL_DEPTH_SIZE, 32);

        sdl_glcontext = enforce!SDLException(SDL_GL_CreateContext(sdl_window),
                SDL_GetError().fromStringz());

        DerelictGL3.reload(GLVersion.GL30);

        glEnable(GL_DEPTH_TEST);
        glDepthFunc(GL_LEQUAL);

        glEnable(GL_BLEND);
        glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
    }

    void draw(double delta)
    {
        glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
        glClearColor(0, 0, 0, 0);
        foreach (drawable; drawables)
        {
            drawable.draw(delta);
        }
        SDL_GL_SwapWindow(sdl_window);
    }
}
