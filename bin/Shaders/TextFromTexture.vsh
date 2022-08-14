// input parameters
uniform mat4 MVP; 
attribute vec3 a_position;
attribute vec2 a_texCoord;
// out parameters
varying vec2 v_texCoord;

void main()
{
	gl_Position = MVP * vec4(a_position, 1.0);
	v_texCoord = a_texCoord;
}
