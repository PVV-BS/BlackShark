#version 330
precision mediump float;
uniform sampler2D s_texture;
uniform vec4 AreaUV; // absolute texture rect, z-width, a-height 
uniform float Opacity;
in vec2 v_texCoord; // relative texture rect
out vec4 outColor;

void main()
{
	outColor = texture2D( s_texture, vec2(AreaUV.x + v_texCoord.x*AreaUV.z, AreaUV.y + v_texCoord.y*AreaUV.a) );
	outColor.a = outColor.a * Opacity;
}
