//#version 130
// input uniform
uniform mat4 MVP; 
// input attributes 
attribute vec4 a_position;
attribute vec2 a_texCoord;
// output parameters 
varying vec2 v_texCoord;

void main()
{
	gl_Position = MVP * a_position;
	v_texCoord = a_texCoord;
}
