precision mediump float;
// uniforms
uniform sampler2D s_texture;
// input color variables
varying vec3 v_color;
varying vec2 v_texCoord; 
varying float v_opacity;


void main()
{
	vec4 cl = texture2D( s_texture, v_texCoord );
	gl_FragColor = vec4(v_color, cl.a * v_opacity);
}
