module rdm.graphics.model;

import rdm.graphics.primatives;
import rdm.graphics.glmesh;
import rdm.graphics.gltexture;

class Model : Drawable3D
{
	GLMesh mesh;
	GLTexture texture;
	
	this(GLMesh mesh, GLTexture texture)
	{
		this.mesh = mesh;
		this.texture = texture;
	}
	
	void draw(double delta)
	{
		texture.bind();
		mesh.draw();
	}
}