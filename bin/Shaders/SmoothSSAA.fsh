precision mediump float;

// Super sampling antialiasing. Provides diffusion with a Filter that
// is passed as a uniform. You probably will want try a Lanczos kernel!

// Uniforms 
uniform sampler2D Texture; 
uniform float RatioResol; // the ratio screen resolution with size near frustum plain
uniform float Kernel[9]; // The smoothing kernel for anti-aliasing

varying vec2 v_texCoord;


void main()
{    
    
	vec4 color = texture2D( Texture, v_texCoord) * Kernel[4];
	color += texture2D( Texture, vec2(v_texCoord.x + RatioResol,  v_texCoord.y  ) ) * Kernel[0];
	color += texture2D( Texture, vec2(v_texCoord.x - RatioResol,  v_texCoord.y  ) ) * Kernel[1];
	color += texture2D( Texture, vec2(v_texCoord.x,  v_texCoord.y + RatioResol  ) ) * Kernel[2];
	color += texture2D( Texture, vec2(v_texCoord.x,  v_texCoord.y - RatioResol  ) ) * Kernel[3];
	color += texture2D( Texture, vec2(v_texCoord.x + RatioResol,   v_texCoord.y + RatioResol  ) ) * Kernel[5];
	color += texture2D( Texture, vec2(v_texCoord.x + RatioResol,   v_texCoord.y - RatioResol  ) ) * Kernel[6];
	color += texture2D( Texture, vec2(v_texCoord.x - RatioResol,   v_texCoord.y + RatioResol  ) ) * Kernel[7];
	color += texture2D( Texture, vec2(v_texCoord.x - RatioResol,   v_texCoord.y - RatioResol  ) ) * Kernel[8];
	gl_FragColor = color;
}