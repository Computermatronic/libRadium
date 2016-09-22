module radium.graphics.event;

private import core.time;
public import derelict.sdl2.sdl;

alias QuitEvent = bool delegate();
alias MouseMoveEvent = bool delegate(SDL_MouseMotionEvent* event, double delta);
alias MouseClickEvent = bool delegate(SDL_MouseButtonEvent* event, double delta);
alias KeyEvent = bool delegate(SDL_KeyboardEvent* event, double delta);
alias UpdateEvent = void delegate(double delta);

class EventManager
{
    QuitEvent[] quitHooks;
    MouseMoveEvent[] moveHooks;
    MouseClickEvent[] clickHooks;
    KeyEvent[] keyDownHooks;
    KeyEvent[] keyUpHooks;
    UpdateEvent[] updateHooks;

    void dispatchEvent(SDL_Event* sdl_event, double delta)
    {
        switch (sdl_event.type)
        {
        case SDL_QUIT:
            foreach_reverse (quitHook; quitHooks)
                if (!quitHook())
                    break;
            break;
        case SDL_MOUSEMOTION:
            auto event = &sdl_event.motion;
            foreach_reverse (moveHook; moveHooks)
                if (!moveHook(event, delta))
                    break;
            break;
        case SDL_MOUSEBUTTONDOWN:
            auto event = &sdl_event.button;
            foreach_reverse (clickHook; clickHooks)
                if (!clickHook(event, delta))
                    break;
            break;
        case SDL_KEYDOWN:
            auto event = &sdl_event.key;
            foreach_reverse (keyDownHook; keyDownHooks)
                if (!keyDownHook(event, delta))
                    break;
            break;
        case SDL_KEYUP:
            auto event = &sdl_event.key;
            foreach_reverse (keyUpHook; keyUpHooks)
                if (!keyUpHook(event, delta))
                    break;
            break;
        default:
            break;
        }
    }

    void update(double delta)
    {
        foreach_reverse (updateHook; updateHooks)
            updateHook(delta);
    }
}
