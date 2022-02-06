// in
uniform mat4 MVP;
uniform vec4 Color;
attribute vec4 a_position;
// out
varying vec4 v_color;
void main()
{
	gl_Position = MVP * a_position;
	v_color = Color;
}
