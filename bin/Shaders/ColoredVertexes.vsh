// input parameters / входные данные
uniform mat4 MVP; 

attribute vec3 a_position;
attribute vec3 a_color;

varying vec3 v_color;

void main()
{
  gl_Position = MVP * vec4(a_position, 1.0);
  v_color = a_color;
}
