// input parameters
attribute vec3 Position;
// outout parameters
varying vec2 v_texCoord;

void main()
{
	gl_Position =  vec4(Position, 1.0);
	v_texCoord = Position.xy*0.5 + vec2(0.5, 0.5);
}
