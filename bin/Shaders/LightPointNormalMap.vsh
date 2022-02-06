// input parameters / ������� ������
uniform mat4 MVP; 
uniform mat4 model;
uniform vec3 viewPosition;

// Point source light attribute / ��������� ���������� ��������� ���������
uniform vec4 LightPosition;

attribute vec3 a_position;
//attribute vec3 a_normal;
attribute vec2 a_texCoord;

// outout parameters / �������� ������
varying vec2 v_texCoord;
varying vec3 v_lightDir;
varying vec3 v_viewDir;
varying float v_distance;

void main()
{
	// ��������� ���������� ������� � ������� ������� ���������
	vec4 vertex = model * vec4(a_position, 1.0);

	// ����������� �� ������� �� �������� ��������� � ������� ������� ���������
	vec4 lightDir = LightPosition - vertex;
	

	// ��������� �� ����������� ������ ��������� ���������
	// �������� ���������� ����������
	v_texCoord = a_texCoord;
	// �������� ����������� �� �������� ���������
	v_lightDir = vec3(lightDir);
	// �������� ����������� �� ������� � ����������� � ������� ������� ���������
	v_viewDir  = viewPosition - vec3(vertex);
	// �������� ���������� �� ������� �� ��������� ���������
	v_distance = length(lightDir);

	// ��������� ���������� ������� � ����������
	gl_Position = MVP * vec4(a_position, 1.0);
 }
