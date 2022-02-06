precision mediump float;
uniform sampler2D s_texture;
uniform float Opacity;
uniform vec4 Color;
varying vec2 v_texCoord; 

const float THREADSH = 0.01;

void main()
{
	gl_FragColor = texture2D( s_texture,  v_texCoord);
	if (gl_FragColor.a > THREADSH)
	{	
		gl_FragColor.xyz = Color.xyz;
		gl_FragColor.a = gl_FragColor.a * Opacity;
	} else
		gl_FragColor.a = 0.0;
}
