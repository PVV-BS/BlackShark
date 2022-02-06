precision mediump float;
uniform float Opacity;

varying vec3 v_color;

void main()
{
  gl_FragColor.xyz = v_color;
  gl_FragColor.a = Opacity;
}
