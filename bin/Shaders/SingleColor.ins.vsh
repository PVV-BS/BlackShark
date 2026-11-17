#version 300 es
layout (location = 0) in vec3 a_position;
layout (location = 1) in vec4 a_Color;
layout (location = 2) in mat4 MVP;

out vec4 inColor;

void main()
{
	gl_Position = MVP * vec4(a_position, 1.0);
    inColor = a_Color;
}