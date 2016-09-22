module radium.graphics.engine;

import core.time;

import std.exception : enforce;
import std.string;

import radium.graphics.utils;
import radium.graphics.event;
import radium.graphics.core.primatives;

import derelict.sdl2.sdl;
import derelict.opengl3.gl3;

class GraphicsEngine
{
    SDL_Window* window;

    uint videoWidth, videoHeight;
    bool running;

    EventManager eventManager;
    Drawable[] drawables;

    this(uint videoWidth, uint videoHeight, string windowTitle = "", uint flags = 0)
    {
        this.videoWidth = videoWidth;
        this.videoHeight = videoHeight;
        DerelictSDL2.load();
        DerelictGL3.load();
        enforce!SDLException(SDL_Init(SDL_INIT_EVERYTHING) == 0, "Failed to load SDL2");

        window = enforce!SDLException(SDL_CreateWindow(windowTitle.toStringz,
                SDL_WINDOWPOS_CENTERED, SDL_WINDOWPOS_CENTERED,
                videoWidth, videoHeight, SDL_WINDOW_OPENGL | flags), "Failed to create SDL window");
        SDL_GL_SetAttribute(SDL_GL_CONTEXT_MAJOR_VERSION, 3);
        SDL_GL_SetAttribute(SDL_GL_CONTEXT_MINOR_VERSION, 0);
        SDL_GL_SetAttribute(SDL_GL_DOUBLEBUFFER, 1);
        SDL_GL_SetAttribute(SDL_GL_DEPTH_SIZE, 32);
        enforce!SDLException(SDL_GL_CreateContext(window), "Failed to create SDL opengl context");
        DerelictGL3.reload(GLVersion.GL30);
        glEnable(GL_DEPTH_TEST);
        glEnable(GL_BLEND);
        glDepthFunc(GL_LEQUAL);
        glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
        eventManager = new EventManager();
        eventManager.quitHooks ~= &quit;
    }

    void add(Drawable d)
    {
        drawables ~= d;
    }

    void run()
    {
        running = true;
        loop();
    }

    bool quit()
    {
        running = false;
        return true;
    }

    void loop()
    {
        auto lastTime = MonoTime.currTime;
        auto delta = 0.seconds;
        double dt;
        while (running)
        {
            tick(dt);
            auto currTime = MonoTime.currTime;
            delta = lastTime - currTime;
            lastTime = currTime;
            dt = (cast(double)delta.total!"nsecs"()) / 1000000000.0;
        }
    }

    void tick(double dt)
    {
        glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
        glClearColor(0, 0, 0, 0);
        foreach (drawable; drawables)
        {
            drawable.draw(dt);
        }
        SDL_GL_SwapWindow(window);
        SDL_Event sdl_event;
        while (SDL_PollEvent(&sdl_event))
        {
            eventManager.dispatchEvent(&sdl_event, dt);
        }
        eventManager.update(dt);
    }
}
