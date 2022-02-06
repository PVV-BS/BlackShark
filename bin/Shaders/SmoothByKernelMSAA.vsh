precision mediump float;
// input parameters
attribute vec3 Position;
// outout parameters
varying vec2 v_texCoord;

void main()
{
	gl_Position = vec4(Position, 1.0);
	v_texCoord = (Position.xy + vec2(1.0, 1.0))*0.5;
}
