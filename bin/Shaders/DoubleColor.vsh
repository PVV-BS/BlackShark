// input parameters
uniform mat4 MVP; 
attribute vec3 a_position;
attribute float a_index_color;

varying float index_color;

void main()
{
  gl_Position = MVP * vec4(a_position.x, a_position.y, 0.0, 1.0);
  index_color = a_index_color; 
}
