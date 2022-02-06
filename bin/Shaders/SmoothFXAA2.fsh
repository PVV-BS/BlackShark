precision mediump float;

uniform vec2 Resolution;
uniform vec2 InvResolution;
uniform sampler2D Texture;

varying vec2 vUv;

//texcoords computed in vertex step
//to avoid dependent texture reads
varying vec2 v_rgbNW;
varying vec2 v_rgbNE;
varying vec2 v_rgbSW;
varying vec2 v_rgbSE;
varying vec2 v_rgbM;

const float FXAA_REDUCE_MIN =  (1.0 / 32.0);
const float FXAA_REDUCE_MUL =  (1.0 / 32.0);
const float FXAA_SPAN_MAX   =  8.0;
const float FXAA_MULT_DIR_1 = (1.0 / 3.0 - 0.5);
const float FXAA_MULT_DIR_2 = (2.0 / 3.0 - 0.5);

void main() 
{

  //optimized version for mobile, where dependent 
  //texture reads can be a bottleneck
  //can also use gl_FragCoord.xy
  mediump vec2 fragCoord = vUv * Resolution; 
  vec3 rgbNW = texture2D(Texture, v_rgbNW).xyz;
  vec3 rgbNE = texture2D(Texture, v_rgbNE).xyz;
  vec3 rgbSW = texture2D(Texture, v_rgbSW).xyz;
  vec3 rgbSE = texture2D(Texture, v_rgbSE).xyz;
  vec4 texColor = texture2D(Texture, v_rgbM);
  vec3 rgbM  = texColor.xyz;
  vec3 luma = vec3(0.299, 0.587, 0.114);
  float lumaNW = dot(rgbNW, luma);
  float lumaNE = dot(rgbNE, luma);
  float lumaSW = dot(rgbSW, luma);
  float lumaSE = dot(rgbSE, luma);
  float lumaM  = dot(rgbM,  luma);
  float lumaMin = min(lumaM, min(min(lumaNW, lumaNE), min(lumaSW, lumaSE)));
  float lumaMax = max(lumaM, max(max(lumaNW, lumaNE), max(lumaSW, lumaSE)));
    
  mediump vec2 dir;
  dir.x = -((lumaNW + lumaNE) - (lumaSW + lumaSE));
  dir.y =  ((lumaNW + lumaSW) - (lumaNE + lumaSE));
    
  float dirReduce = max((lumaNW + lumaNE + lumaSW + lumaSE) *
                          (0.25 * FXAA_REDUCE_MUL), FXAA_REDUCE_MIN);
    
  float rcpDirMin = 1.0 / (min(abs(dir.x), abs(dir.y)) + dirReduce);
  dir = min(vec2(FXAA_SPAN_MAX, FXAA_SPAN_MAX),
              max(vec2(-FXAA_SPAN_MAX, -FXAA_SPAN_MAX),
              dir * rcpDirMin)) * InvResolution;
    
  vec3 rgbA = 0.5 * (
        texture2D(Texture, fragCoord * InvResolution + dir * FXAA_MULT_DIR_1).xyz +
        texture2D(Texture, fragCoord * InvResolution + dir * FXAA_MULT_DIR_2).xyz);
  vec3 rgbB = rgbA * 0.5 + 0.25 * (
        texture2D(Texture, fragCoord * InvResolution + dir * -0.5).xyz +
        texture2D(Texture, fragCoord * InvResolution + dir * 0.5).xyz);

  float lumaB = dot(rgbB, luma);
  if ((lumaB < lumaMin) || (lumaB > lumaMax))
      gl_FragColor = vec4(rgbA, texColor.a);
  else
      gl_FragColor = vec4(rgbB, texColor.a);

} 