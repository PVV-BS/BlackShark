precision mediump float;
uniform float Opacity;

varying vec4 v_color;

void main()
{
  gl_FragColor = vec4(v_color.xyz, v_color.a*Opacity);
}
