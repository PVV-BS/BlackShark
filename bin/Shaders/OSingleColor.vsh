// input parameters / ������� ������
uniform mat4 MVP; 
attribute vec4 a_position;

void main()
{
	gl_Position = MVP * a_position;
}
