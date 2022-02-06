precision mediump float;
// Point source light attribute / параметры точеченого источника освещения
//uniform vec4 LightPosition;
uniform vec4 LightAmbient;
uniform vec4 LightDiffuse;
uniform vec4 LightSpecular;
uniform vec3 LightAttenuation;

// параметры материала
uniform sampler2D s_texture;
uniform vec4 ambient;
uniform vec4 diffuse;
uniform vec4 specular;
uniform vec4 emission;
uniform float shininess;


// параметры полученные из вершинного шейдера
varying vec2 v_texCoord;
varying vec3 v_normal;
varying vec3 v_lightDir;
varying vec3 v_viewDir;
varying float v_distance;

void main(void)
{
  // нормализуем полученные данные для коррекции интерполяции
  vec3 normal   = normalize(v_normal);
  vec3 lightDir = normalize(v_lightDir);
  vec3 viewDir  = normalize(v_viewDir);

  // коэффициент затухания
  float attenuation = 1.0 / (LightAttenuation[0] +
    LightAttenuation[1] * v_distance +
    LightAttenuation[2] * v_distance * v_distance);

  // добавим собственное свечение материала
  gl_FragColor = emission;

  // добавим фоновое освещение
  gl_FragColor += ambient * LightAmbient * attenuation;

  // добавим рассеянный свет
  float NdotL = max(dot(normal, lightDir), 0.0);
  gl_FragColor += diffuse * LightDiffuse * NdotL * attenuation;

  // добавим отраженный свет
  float RdotVpow = max(pow(dot(reflect(-lightDir, normal), viewDir), shininess), 0.0);
  gl_FragColor += specular * LightSpecular * RdotVpow * attenuation;

  // вычислим итоговый цвет пикселя на экране с учетом текстуры
  // gl_FragColor *= texture2D(s_texture, vec2(v_texCoord.x, v_texCoord.y * 0.5));
  gl_FragColor *= texture2D(s_texture, v_texCoord);
}