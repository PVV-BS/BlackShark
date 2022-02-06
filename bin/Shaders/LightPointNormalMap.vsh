// input parameters / входные данные
uniform mat4 MVP; 
uniform mat4 model;
uniform vec3 viewPosition;

// Point source light attribute / параметры точеченого источника освещения
uniform vec4 LightPosition;

attribute vec3 a_position;
//attribute vec3 a_normal;
attribute vec2 a_texCoord;

// outout parameters / выходные данные
varying vec2 v_texCoord;
varying vec3 v_lightDir;
varying vec3 v_viewDir;
varying float v_distance;

void main()
{
	// переведем координаты вершины в мировую систему координат
	vec4 vertex = model * vec4(a_position, 1.0);

	// направление от вершины на источник освещения в мировой системе координат
	vec4 lightDir = LightPosition - vertex;
	

	// передадим во фрагментный шейдер некоторые параметры
	// передаем текстурные координаты
	v_texCoord = a_texCoord;
	// передаем направление на источник освещения
	v_lightDir = vec3(lightDir);
	// передаем направление от вершины к наблюдателю в мировой системе координат
	v_viewDir  = viewPosition - vec3(vertex);
	// передаем рассятоние от вершины до источника освещения
	v_distance = length(lightDir);

	// переводим координаты вершины в однородные
	gl_Position = MVP * vec4(a_position, 1.0);
 }
