module src.demo.simple;

import std.stdio;

import radium.graphics.engine;
import radium.graphics.core.layer;
import radium.graphics.core.camera;
import radium.graphics.render.mesh;
import radium.graphics.render.model;
import radium.graphics.utils;
import radium.graphics.render.material;
import radium.graphics.render.texture;
import radium.graphics.render.shader;
import radium.graphics.event;
import radium.math;
import radium.assets.rdmesh;
import radium.streams.filestream;

string fragmentShader = `
#version 150

uniform sampler2D iTexture1;

in vec2 vTextureCoordinate;

void main()
{
    gl_FragColor = texture(iTexture1, vec2(vTextureCoordinate.x * 20, vTextureCoordinate.y * 20));
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

void main()
{
    auto engine = new GraphicsEngine(640, 480);
    auto layer = new Layer(0, 0, 640, 480, true);
    engine.add(layer);
    auto camera = new Camera(70.toDegrees(), 640 / 480, 0.1, 1000);
    layer.camera = camera;
    auto mesh = loadRDMesh(new RDMesh(new FileStream("res/mesh.rdm", "rb")));
    //    auto mesh = new Mesh([Vector3f(0, 5, 5), // top
    //            Vector3f(-5, 0, 5), // bottom left
    //            Vector3f(5, 0, 5) // bottom right
    //            ], null, null, null, [0u, 1u, 2u]);
    auto shader = new Shader(vertexShader, fragmentShader);
    auto texture = new Texture();
    auto material = new Material(shader, texture);
    auto model = new Model(mesh, material);
    layer.add(model);
    double sensitivity = 10;
    bool camRot(SDL_MouseMotionEvent* event, double delta)
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
            engine.running = false;
            return true;
        default:
            return true;
        }
        camera.transform.translation += direction.rotate(
                camera.transform.rotation) * delta * 10 * sensitivity;
        return true;
    }

    engine.eventManager.moveHooks ~= &camRot;
    engine.eventManager.keyDownHooks ~= &camTrans;
    engine.run();
}
