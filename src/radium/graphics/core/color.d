module radium.graphics.core.color;

struct Color
{
    float r, g, b, a;

    this(ubyte r, ubyte g, ubyte b, ubyte a)
    {
		this.r = r / ubyte.max;
		this.g = g / ubyte.max;
		this.b = b / ubyte.max;
		this.a = a / ubyte.max;
    }
    
    this(float r, float g, float b, float a)
    {
		this.r = r;
		this.g = g;
		this.b = b;
		this.a = a;
    }
}
