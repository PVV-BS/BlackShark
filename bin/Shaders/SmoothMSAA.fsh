// Multi sampling antialiasing. Provides small blur effect in depended from bias arround v_texCoord  
precision mediump float;
uniform sampler2D Texture;
uniform float RatioResol; // the ratio screen resolution with size near frustum plain

varying vec2 v_texCoord;

const float PERCENT_BIAS = 0.2;

void main()
{
	float bias = RatioResol * PERCENT_BIAS;
	gl_FragColor =  texture2D( Texture,  v_texCoord);
	gl_FragColor += texture2D( Texture, vec2(v_texCoord.x + bias, v_texCoord.y  ) );
	gl_FragColor += texture2D( Texture, vec2(v_texCoord.x - bias, v_texCoord.y  ) );
	gl_FragColor += texture2D( Texture, vec2(v_texCoord.x,  v_texCoord.y + bias) );
	gl_FragColor += texture2D( Texture, vec2(v_texCoord.x,  v_texCoord.y - bias) );
	gl_FragColor += texture2D( Texture, vec2(v_texCoord.x + bias, v_texCoord.y + bias  ) );
	gl_FragColor += texture2D( Texture, vec2(v_texCoord.x + bias, v_texCoord.y - bias  ) );
	gl_FragColor += texture2D( Texture, vec2(v_texCoord.x - bias,   v_texCoord.y + bias) );
	gl_FragColor += texture2D( Texture, vec2(v_texCoord.x - bias,   v_texCoord.y - bias) );
	gl_FragColor = gl_FragColor/9.0;
}
