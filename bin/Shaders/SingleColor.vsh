// input parameters
uniform mat4 MVP; 
attribute vec3 a_position;

void main()
{
	gl_Position = MVP * vec4(a_position, 1.0);
}

