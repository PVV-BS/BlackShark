// input parameters / входные данные
uniform mat4 MVP; 
attribute vec4 a_position;
attribute vec2 a_texCoord;
// outout parameters / выходные данные
varying vec2 v_texCoord;

void main()
{
	gl_Position = MVP * a_position;
	v_texCoord = a_texCoord;
}
