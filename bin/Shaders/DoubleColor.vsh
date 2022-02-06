// input parameters / входные данные
uniform mat4 MVP; 
attribute vec4 a_position;

varying float index_color;

void main()
{
  gl_Position = MVP * vec4(a_position.x, a_position.y, 0.0, 1.0);
	index_color = a_position.z; //int(a_position.z) & 1;
}
