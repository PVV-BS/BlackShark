precision mediump float;
uniform sampler2D s_texture;
uniform sampler2D s_texture2;
uniform float Time; // [0 .. 1.0]
uniform vec4 AreaUV; // absolute texture rect 
uniform float Opacity;
varying vec2 v_texCoord; // relative texture rect

void main()
{
	
	vec4 color1 = (1.0 - Time) * texture2D( s_texture, vec2(AreaUV.x + v_texCoord.x*AreaUV.z, AreaUV.y + v_texCoord.y*AreaUV.a) );
	vec4 color2 = Time * texture2D( s_texture2, vec2(AreaUV.x + v_texCoord.x*AreaUV.z, AreaUV.y + v_texCoord.y*AreaUV.a) );
	
	gl_FragColor = (color1 + color2);
	gl_FragColor.a = gl_FragColor.a * Opacity;
}
