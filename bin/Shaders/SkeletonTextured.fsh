precision mediump float;
uniform float Opacity;
uniform sampler2D s_texture;
uniform vec4 AreaUV; // absolute texture rect, z-width, a-height 
varying vec2 v_texCoord; // relative texture rect

void main()
{
	gl_FragColor = texture2D( s_texture, vec2(AreaUV.x + v_texCoord.x*AreaUV.z, AreaUV.y + v_texCoord.y*AreaUV.a) );
	gl_FragColor.a = gl_FragColor.a * Opacity;
}
