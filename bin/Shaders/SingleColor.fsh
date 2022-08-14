precision mediump float;
uniform float Opacity;
uniform vec4 Color;

void main()
{
  // for vector fonts not need texture, because use only Color
  gl_FragColor = vec4(Color.x, Color.y, Color.z, Color.a*Opacity);
}
