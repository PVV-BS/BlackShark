// input uniforms
uniform vec2 uv[4];
uniform vec3 quad[4];
uniform mat4 MVP; 
// input attributes
attribute vec4 a_position;
// output parameters
varying vec2 v_texCoord;

void main()
{
	gl_Position = MVP*vec4(a_position.xyz + quad[int(a_position.a)], 1.0);//
	v_texCoord = uv[int(a_position.a)]; 
}
