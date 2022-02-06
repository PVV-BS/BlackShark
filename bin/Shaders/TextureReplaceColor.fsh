//#version 130
precision mediump float; //mediump float;

uniform sampler2D s_texture;
uniform vec4 AreaUV; // absolute texture rect, z-width, a-height 
uniform float Opacity;
uniform vec3 HLS;
varying vec2 v_texCoord; // relative texture rect


const float HLSMAX = 0.9411764;
const float HLSMAX_HALF = 0.4705882;
const float HLSMAX6 = 5.6470584;
const float HLSMAX_PART_6 = 0.1568621; // 0.1568621058824
const float HLSMAX_PART_2_3 = 0.62745; // 0.6274503058824

float HueToRGB(float hue, float p, float q)
{
  float h;	
  if (hue < 0.0)
    h = hue + HLSMAX; else
  if (hue > HLSMAX) 
    h = hue - HLSMAX; else
	h = hue; 
  if (h < HLSMAX_PART_6) // 1/6
    return (p + ((q-p)*h*HLSMAX6)); else
	//return ((q-p)*h);
  if (h < HLSMAX_HALF)
    return q; else
  if (h < HLSMAX_PART_2_3) // 2/3
  {
	//h = HLSMAX_PART_6*(HLSMAX_PART_2_3-h);
	//h = 0.0984 - h * HLSMAX_PART_6;
	h = h * HLSMAX_PART_6;
	return h;//p + 
	//return float(((q-p)*h));//p + 
  }
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
    return vec3(HueToRGB(HLS.x+0.333333*HLSMAX, p, q), HueToRGB(HLS.x*HLSMAX, p, q), HueToRGB(HLS.x-0.333333*HLSMAX, p, q));
  }
}

void main()
{
	vec4 c_tex = texture2D( s_texture, vec2(AreaUV.x + v_texCoord.x*AreaUV.z, AreaUV.y + v_texCoord.y*AreaUV.a) );
	float cMax = max( max(c_tex.r, c_tex.g), c_tex.b);
	float cMin = min( min(c_tex.r, c_tex.g), c_tex.b);
	gl_FragColor = vec4(HLStoRGB(vec3(HLS.x, (cMax+cMin)*0.5, HLS.z)), c_tex.a * Opacity);
	//gl_FragColor = vec4(vec3(c_tex.x*HLS.x, c_tex.y*HLS.y, c_tex.z*HLS.z), c_tex.a * Opacity);
}
