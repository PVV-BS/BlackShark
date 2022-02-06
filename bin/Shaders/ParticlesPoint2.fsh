precision mediump float;
uniform vec3 v_color;
// input color variables
varying float v_opacity;

void main()
{
	gl_FragColor = vec4(v_color, v_opacity);
}
