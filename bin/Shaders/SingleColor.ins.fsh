#version 300 es
precision mediump float;
uniform float Opacity;

in vec4 inColor;

out vec4 fragColor;

void main()
{
  // for vector fonts not need texture, because use only Color
  fragColor = vec4(inColor.xyz, inColor.a*Opacity);  
}
