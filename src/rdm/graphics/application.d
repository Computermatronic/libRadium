module rdm.graphics.application;

import rdm.graphics.display;
import rdm.graphics.event;

class Application
{
    Display display;
    EventManager eventManager;
    bool running;

    this(string title, size_t width, size_t height, uint flags = 0)
    {
        this(new Display(title, width, height, 0), new EventManager());
    }

    this(Display display, EventManager eventManager)
    {
        this.display = display;
        this.eventManager = eventManager;
        this.eventManager.closeHooks ~= &stop;
    }

    void run()
    {
        running = true;
        loop();
    }

    NextEventProcedure stop()
    {
        running = false;
        return NextEventProcedure.propergate;
    }

    void loop()
    {
        import core.time;
		
        auto lastTime = MonoTime.currTime;
        auto elapsed = 0.seconds;
        double delta;
        while (running)
        {
            auto currTime = MonoTime.currTime;
            elapsed = lastTime - currTime;
            lastTime = currTime;
            delta = (cast(double) elapsed.total!"nsecs"()) / 1000000000.0;
            display.draw(delta);
            eventManager.update(delta);
        }
        eventManager.quit();
    }
}
