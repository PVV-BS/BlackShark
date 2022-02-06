// input parameters 
uniform mat4 MVP; 

attribute vec3 a_position;
attribute float a_distance;

varying float v_distance;

void main()
{
  gl_Position = MVP * vec4(a_position, 1.0);
  v_distance = a_distance;
}
