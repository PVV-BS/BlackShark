precision mediump float;
uniform float Opacity;
uniform vec4 Color;

void main()
{
	// for vector fonts not need texture, because use only Color
	//gl_FragColor = vec4(1.0, 0.0, 0.0, 1.0);
  gl_FragColor.xyz = Color.xyz;
	gl_FragColor.a = Color.a * Opacity;
}
