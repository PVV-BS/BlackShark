precision mediump float;
// uniforms
uniform sampler2D s_texture;
// input color variables
varying vec2 v_texCoord; 
varying float v_opacity;


void main()
{
	gl_FragColor = texture2D( s_texture, v_texCoord );
	//gl_FragColor.xyz = vec3(1.0, 0.0, 1.0);
	gl_FragColor.a = gl_FragColor.a * v_opacity;
}
