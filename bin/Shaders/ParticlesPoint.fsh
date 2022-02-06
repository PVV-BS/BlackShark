precision mediump float;
// input color variables
varying float v_opacity;
varying vec3 v_color;

void main()
{
	gl_FragColor = vec4(v_color, v_opacity);
}
