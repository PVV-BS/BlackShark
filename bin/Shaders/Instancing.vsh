#version 330
// input attributes 
layout(location = 0) in vec4 a_position;
layout(location = 1) in vec2 a_texCoord;
layout(location = 2) in mat4 MVP; 
// output parameters 
out vec2 v_texCoord;

void main()
{
	gl_Position = MVP * a_position;
	v_texCoord = a_texCoord;
}
