module radium.graphics.core.layer;

import radium.graphics.core.primatives;

import radium.math.matrix;

import derelict.opengl3.gl3;

class Layer : Drawable
{

    int x, y, width, height; //viewport location
    Projector camera;
    Drawable[] drawables;
    bool visible;

    this(int x, int y, int width, int height, bool visible)
    {
        this.x = x;
        this.y = y;
        this.width = width;
        this.height = height;
        this.visible = visible;
    }

    void add(Drawable d)
    {
        drawables ~= d;
    }

    void draw(double dt, Matrix4f* mat = null)
    {
        if (!visible)
            return;
        Matrix4f projection = Matrix4f.identity();
        glViewport(x, y, x + width, y + height);
        if (camera !is null)
            projection = camera.getProjection();
        foreach (drawable; drawables)
        {
            drawable.draw(dt, &projection);
        }
    }
}
