precision mediump float;
uniform sampler2D s_texture;
uniform vec4 AreaUV; // absolute texture rect 
uniform float Opacity;
uniform vec4 Color;
varying vec2 v_texCoord; // relative texture rect

//const float smoothing = 1.0/16.0;
//const float BIAS = 0.0095;
const float THREADSH = 0.01;

void main()
{
	vec2 uv = vec2(AreaUV.x + v_texCoord.x*AreaUV.z, AreaUV.y + v_texCoord.y*AreaUV.a);
	gl_FragColor = texture2D( s_texture,  uv);
	if (gl_FragColor.a > THREADSH)
	{	
		/*vec4 v;
		v = texture2D( s_texture, vec2(uv.x + BIAS, uv.y) );
		if (v.a <= THREADSH)
			gl_FragColor.a = gl_FragColor.a * (1.0+THREADSH);
			
		v = texture2D( s_texture, vec2(uv.x - BIAS, uv.y) );
		if (v.a <= THREADSH)
			gl_FragColor.a = gl_FragColor.a * (1.0+THREADSH);
			
		v = texture2D( s_texture, vec2(uv.x, uv.y + BIAS) );
		if (v.a <= THREADSH)
			gl_FragColor.a = gl_FragColor.a * (1.0+THREADSH);

		v = texture2D( s_texture, vec2(uv.x, uv.y - BIAS) );
		if (v.a <= THREADSH)
			gl_FragColor.a = gl_FragColor.a * (1.0+THREADSH);
		
		v = texture2D( s_texture, vec2(uv.x + BIAS, uv.y + BIAS) );
		if (v.a <= THREADSH)
			gl_FragColor.a = gl_FragColor.a * (1.0+THREADSH);

		v = texture2D( s_texture, vec2(uv.x - BIAS, uv.y + BIAS) );
		if (v.a <= THREADSH)
			gl_FragColor.a = gl_FragColor.a * (1.0+THREADSH);

		v = texture2D( s_texture, vec2(uv.x + BIAS, uv.y - BIAS) );
		if (v.a <= THREADSH)
			gl_FragColor.a = gl_FragColor.a * (1.0+THREADSH);

		v = texture2D( s_texture, vec2(uv.x - BIAS, uv.y - BIAS) );
		if (v.a <= THREADSH)
			gl_FragColor.a = gl_FragColor.a * (1.0+THREADSH);
		
		if (gl_FragColor.a > 1.0)
			gl_FragColor.a = 1.0;*/
			

			//gl_FragColor.a = smoothstep(1.0, 1.0, gl_FragColor.a);
		gl_FragColor.xyz = Color.xyz;
		gl_FragColor.a = gl_FragColor.a * Opacity;
	} else
	//if (gl_FragColor.a > 0.01)
	//	gl_FragColor.a = gl_FragColor.a * Opacity;
	//else
		gl_FragColor.a = 0.0;
}
