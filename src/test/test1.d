module test1;

import std.typecons : scoped;

import rdm.graphics;
import rdm.math;
import rdm.asset;
import rdm.stream;

void main()
{
    auto app = new Application("Test 1", 640, 480);
    auto layer = new Layer3D();
    auto shader = new Shader(vertexShader, fragmentShader);
    auto camera = new Camera(70.toDegrees(), 640 / 480, 0.1, 1000);
    //    auto meshAsset = new RDMesh(scoped!FileStream("res/mesh.rdm", "rb"));
    auto mesh = GLMesh([Vector3f(0, 5, 5), Vector3f(-5, 0, 5), Vector3f(5, 0, 5)],
            null, null, null, [0u, 1u, 2u]);
    auto texture = GLTexture();
    auto model = new Model(mesh, texture);
    layer.shader = shader;
    layer.camera = camera;
    layer.drawables.add(model);
    app.display.drawables.add(layer);

    double sensitivity = 10;
    bool rotateCamera(SDL_MouseMotionEvent* event, double delta)
    {
        if (event.state & SDL_BUTTON(SDL_BUTTON_LEFT))
        {
            camera.transform.rotation = Quaternion(Vector3f(0, 1, 0),
                    delta * -event.xrel * sensitivity) * camera.transform.rotation;
            camera.transform.rotation = Quaternion(Vector3f(1, 0, 0)
                    .rotate(camera.transform.rotation), delta * -event.yrel * sensitivity)
                * camera.transform.rotation;
        }
        return true;
    }

    bool camTrans(SDL_KeyboardEvent* event, double delta)
    {
        Vector3f direction;
        switch (event.keysym.sym)
        {
        case SDLK_w:
            direction = Vector3f(0, 0, 1);
            break;
        case SDLK_s:
            direction = Vector3f(0, 0, -1);
            break;
        case SDLK_a:
            direction = Vector3f(-1, 0, 0);
            break;
        case SDLK_d:
            direction = Vector3f(1, 0, 0);
            break;
        case SDLK_q:
            direction = Vector3f(0, 1, 0);
            break;
        case SDLK_z:
            direction = Vector3f(0, -1, 0);
            break;
        case SDLK_1:
            camera.transform.rotation = Quaternion();
            return true;
        case SDLK_2:
            camera.transform.translation = Vector3f(0, 0, 0);
            return true;
        case SDLK_UP:
            camera.transform.rotation = Quaternion(Vector3f(0, 1, 0),
                    delta * sensitivity) * camera.transform.rotation;
            break;
        case SDLK_ESCAPE:
            app.stop();
            return true;
        default:
            return true;
        }
        camera.transform.translation += direction.rotate(
                camera.transform.rotation) * delta * 10 * sensitivity;
        return true;
    }

    app.run();
}

string fragmentShader = `
#version 150

uniform sampler2D iTexture1;

in vec2 vTextureCoordinate;

void main()
{
    gl_FragColor = vec4(1,1,1,1);//texture(iTexture1, vec2(vTextureCoordinate.x * 20, vTextureCoordinate.y * 20));
}
`;

string vertexShader = `
#version 150

uniform mat4 iMVP;

in vec4 iPosition;
in vec2 iTextureCoordinate;

out vec2 vTextureCoordinate;

void main()
{
	vTextureCoordinate = iTextureCoordinate;
    gl_Position = iMVP * iPosition;
}
`;
