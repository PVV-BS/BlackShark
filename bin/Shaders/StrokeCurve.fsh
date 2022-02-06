precision mediump float;
uniform float Opacity;
uniform float StrokeLen;
uniform vec4 Color;

varying float v_distance;

void main()
{
  float a = Color.w;
  
  if (StrokeLen > 0.0)
  {
  
    int count = int(v_distance / StrokeLen);
    
    if (int(count - 2 * int(count / 2)) > 0) 
	    a =  0.0;
	  
  }
  	
  gl_FragColor = vec4(Color.xyz, a*Opacity);
}
