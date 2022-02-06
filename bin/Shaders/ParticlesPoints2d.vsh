// uniforms
uniform mat3 View; 
uniform vec3 BasePosition;
uniform vec2 ScreenMetrics;
uniform float PointSize;

// input attributes
attribute vec2 a_offsets;

void main()
{
	// 
	gl_Position = vec4(View * vec3(BasePosition.x + a_offsets.x * ScreenMetrics.x, BasePosition.y - a_offsets.y * ScreenMetrics.y, BasePosition.z), 1.0);
	gl_PointSize = PointSize;
}