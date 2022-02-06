precision mediump float;
// uniforms
uniform sampler2D s_texture;
// in advance calculated HLS color 
uniform vec3 HLS;
varying vec2 v_texCoord; 
varying float v_opacity;

const float HLSMAX = 0.9411764;

float HueToRGB(float hue, float p, float q)
{
  float h;	
  if (hue < 0.0)
    h = hue + HLSMAX; else
  if (hue > HLSMAX) 
    h = hue - HLSMAX; else
	h = hue;
  if (h < 0.166666*HLSMAX) // 1/6
    return (p + ((q-p)*6.0*h*HLSMAX)); else
  if (h < 0.5*HLSMAX)
    return q; else
  if (h < 0.666666*HLSMAX) // 2/3
    return (p + ((q-p)*6.0*HLSMAX*(0.666666*HLSMAX-h)));
  return p;
}

vec3 HLStoRGB(vec3 HLS)
{  
  if (HLS.z == 0.0)
  {
    // gray scale  
    return vec3(HLS.y, HLS.y, HLS.y);
  } else
  {
	float p, q;
    if (HLS.y > 0.5*HLSMAX)
      q = (HLS.y + HLS.z - (HLS.y*HLS.z)*HLSMAX); else 
      q = (HLS.y * (HLSMAX + HLS.z));  
	p = HLS.y*2.0 - q;
    return vec3(HueToRGB(HLS.x+0.333333*HLSMAX, p, q), HueToRGB(HLS.x, p, q), HueToRGB(HLS.x-0.333333*HLSMAX, p, q));
  }
}


void main()
{
	vec4 c_tex = texture2D( s_texture, v_texCoord );
	float cMax = max( max(c_tex.r, c_tex.g), c_tex.b);
	float cMin = min( min(c_tex.r, c_tex.g), c_tex.b);
	gl_FragColor = vec4(HLStoRGB(vec3(HLS.x, (cMax+cMin)*0.5, HLS.z)), c_tex.a * v_opacity);
}
