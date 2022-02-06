precision mediump float;
uniform sampler2D Texture;
varying vec2 v_texCoord;

void main()
{
	gl_FragColor = texture2D( Texture,  v_texCoord);
}
