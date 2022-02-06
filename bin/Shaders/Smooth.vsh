// input parameters
attribute vec3 a_position;
// outout parameters
varying vec2 v_texCoord;

void main()
{
	gl_Position =  vec4(a_position, 1);
	v_texCoord = (a_position.xy + vec2(1,1))/2.0;
}
