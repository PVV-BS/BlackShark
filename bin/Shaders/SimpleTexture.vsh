//#version 130
// input uniform
uniform mat4 MVP; 
// input attributes 
attribute vec3 a_position;
attribute vec2 a_texCoord;
// output parameters 
varying vec2 v_texCoord;

void main()
{
	gl_Position = MVP * vec4(a_position, 1.0);
	v_texCoord = a_texCoord;
}
