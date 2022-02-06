precision mediump float;
// uniforms
uniform sampler2D s_texture;
uniform vec3 color;
// input color variables
varying vec2 v_texCoord; 
varying float v_opacity;


void main()
{
	vec4 cl = texture2D( s_texture, v_texCoord );
	gl_FragColor = vec4(color, cl.a * v_opacity);
}
