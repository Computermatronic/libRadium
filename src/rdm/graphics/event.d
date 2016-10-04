module rdm.graphics.event;

public import derelict.sdl2.sdl;

enum NextEventProcedure
{
	propergate,
	halt
}

alias CloseEvent = NextEventProcedure delegate();
alias QuitEvent = NextEventProcedure delegate();
alias MouseMoveEvent = NextEventProcedure delegate(SDL_MouseMotionEvent* event, double delta);
alias MouseClickEvent = NextEventProcedure delegate(SDL_MouseButtonEvent* event, double delta);
alias KeyEvent = NextEventProcedure delegate(SDL_KeyboardEvent* event, double delta);
alias UpdateEvent = NextEventProcedure delegate(double delta);

class EventManager
{
	CloseEvent[] closeHooks;
    QuitEvent[] quitHooks;
    MouseMoveEvent[] moveHooks;
    MouseClickEvent[] clickHooks;
    KeyEvent[] keyDownHooks;
    KeyEvent[] keyUpHooks;
    UpdateEvent[] updateHooks;

    void update(double delta)
    {
        SDL_Event sdl_event;
        while (SDL_PollEvent(&sdl_event))
        {
            switch (sdl_event.type)
            {
            case SDL_QUIT:
                foreach_reverse (closeHook; closeHooks)
                    if (closeHook() == NextEventProcedure.halt)
                        break;
                break;
            case SDL_MOUSEMOTION:
                auto event = &sdl_event.motion;
                foreach_reverse (moveHook; moveHooks)
                    if (moveHook(event, delta) == NextEventProcedure.halt)
                        break;
                break;
            case SDL_MOUSEBUTTONDOWN:
                auto event = &sdl_event.button;
                foreach_reverse (clickHook; clickHooks)
                    if (clickHook(event, delta) == NextEventProcedure.halt)
                        break;
                break;
            case SDL_KEYDOWN:
                auto event = &sdl_event.key;
                foreach_reverse (keyDownHook; keyDownHooks)
                    if (keyDownHook(event, delta) == NextEventProcedure.halt)
                        break;
                break;
            case SDL_KEYUP:
                auto event = &sdl_event.key;
                foreach_reverse (keyUpHook; keyUpHooks)
                    if (keyUpHook(event, delta) == NextEventProcedure.halt)
                        break;
                break;
            default:
                break;
            }
        }
        foreach_reverse (updateHook; updateHooks)
            if (updateHook(delta) == NextEventProcedure.halt)
                break;
    }

    void quit()
    {
        foreach_reverse (quitHook; quitHooks)
            if (quitHook() == NextEventProcedure.halt)
                break;
    }
}
