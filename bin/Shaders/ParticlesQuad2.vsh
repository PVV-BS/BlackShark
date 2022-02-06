// uniforms
uniform mat4 MVP; 
// input attributes
attribute vec4 a_position;
attribute float a_scale;
attribute float a_opacity; 
attribute vec2 a_uv;
attribute vec2 a_delta; // texture rect
// out parameters
varying vec2 v_texCoord;
varying float v_opacity;

void main()
{
	gl_Position = MVP*vec4(a_position.x + a_delta.x*a_scale, a_position.y + a_delta.y*a_scale, a_position.z, 1.0);
	v_texCoord = a_uv; 
	v_opacity = a_opacity;
}
