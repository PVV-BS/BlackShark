precision mediump float;

// Super sampling antialiasing. 

// Uniforms 
uniform sampler2D Texture; 
uniform float RatioResol; // the ratio screen resolution with size near frustum plain

varying vec2 v_texCoord;


void main()
{    
    
	vec4 color = texture2D( Texture, v_texCoord);
	color += texture2D( Texture, vec2(v_texCoord.x + RatioResol,  v_texCoord.y  ) );
	color += texture2D( Texture, vec2(v_texCoord.x - RatioResol,  v_texCoord.y  ) );
	color += texture2D( Texture, vec2(v_texCoord.x,  v_texCoord.y + RatioResol  ) );
	color += texture2D( Texture, vec2(v_texCoord.x,  v_texCoord.y - RatioResol  ) );
	color += texture2D( Texture, vec2(v_texCoord.x + RatioResol,   v_texCoord.y + RatioResol  ) );
	color += texture2D( Texture, vec2(v_texCoord.x + RatioResol,   v_texCoord.y - RatioResol  ) );
	color += texture2D( Texture, vec2(v_texCoord.x - RatioResol,   v_texCoord.y + RatioResol  ) );
	color += texture2D( Texture, vec2(v_texCoord.x - RatioResol,   v_texCoord.y - RatioResol  ) );
	gl_FragColor = color/9.0;
}