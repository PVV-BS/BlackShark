precision mediump float;
uniform sampler2D s_texture;
uniform float Opacity;
varying vec2 v_texCoord; // relative texture rect

void main()
{
	gl_FragColor = texture2D( s_texture, v_texCoord );//vec4(1.0, 0.0, 0.0, 1.0);//
	gl_FragColor.a = gl_FragColor.a * Opacity;
}
