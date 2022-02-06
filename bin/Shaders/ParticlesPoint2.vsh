// uniforms
uniform mat4 MVP; 
// input attributes
attribute vec4 a_position;
attribute float a_opacity; 
attribute float a_scale;
// out parameters
varying float v_opacity;

void main()
{
	gl_Position = MVP*vec4(a_position.xyz, 1.0);//
	if (a_scale < 1.0)
		gl_PointSize = 1.0; else
		gl_PointSize = a_scale;
	v_opacity = a_opacity;
}