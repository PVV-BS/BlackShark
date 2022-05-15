precision mediump float;
uniform float Opacity;
uniform vec4 Color;
uniform vec4 Color2;

varying float index_color;

void main()
{
  if (index_color > 0.0)
    gl_FragColor.xyz = Color.xyz;
  else
    gl_FragColor.xyz = Color2.xyz;
    
  gl_FragColor.a = Color.a * Opacity;
  
}
