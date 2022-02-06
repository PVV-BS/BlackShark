// input parameters 
uniform mat4 MVP; 

attribute vec3 a_position;
attribute vec4 a_color;
attribute float a_distance;

varying vec4 v_color;
varying float v_distance;

void main()
{
  gl_Position = MVP * vec4(a_position, 1.0);
  v_color = a_color;
  v_distance = a_distance;
}
