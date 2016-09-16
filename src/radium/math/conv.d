module radium.math.conv;

private import std.math;

public float toDegrees(float radians)
{

    return (PI / 180) * radians;
}

public float toRadians(float degrees)
{
	return (180.0 / PI) * degrees;
}