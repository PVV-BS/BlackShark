precision mediump float;
uniform float Opacity;
uniform float StrokeLen;

varying vec4 v_color;
varying float v_distance;

void main()
{
  float a = v_color.w;
  
  if (StrokeLen > 0.0)
  {
  
    int count = int(v_distance / StrokeLen);
    
    if (int(count - 2 * int(count / 2)) > 0) 
	    a =  0.0;
	  
  }
  	
  gl_FragColor = vec4(v_color.xyz, a*Opacity);
}
