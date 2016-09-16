module src.demo.simple;

import radium.graphics.engine;
import radium.graphics.core.layer;
import radium.graphics.core.camera;
import radium.graphics.render.model;
import radium.graphics.utils;
import radium.graphics.render.material;
import radium.graphics.render.shader;
import radium.math.conv;
import radium.assets.rdmesh;
import radium.streams.filestream;

string fragmentShader =
`
#version 110

void main()
{
    gl_FragColor = vec4(1.0, 0.0, 0.0, 1.0);
}
`;

string vertexShader =
`
#version 110
in vec4 iPosition;
uniform mat4f iMVP;

void main()
{
    gl_Position = iMVP * iPosition;
}
`;

void main()
{
	auto engine = new GraphicsEngine(640, 480);
	auto layer = new Layer(0,0,640,480,true);
	engine.add(layer);
	auto camera = new Camera(70.toDegrees(), 640 / 480, 0.1, 1000);
	layer.camera = camera;
	auto mesh = loadRDMesh(new RDMesh(new FileStream("../res/mesh.rdm","rb")));
	auto shader = new Shader(vertexShader, fragmentShader);
	auto material = new Material(shader, null);
	auto model = new Model(mesh, material);
	engine.add(model);
	engine.run();
}
