//precision highp float;
// input parameters 

// when will change it value here, change it in TBlackSharkSkeletonShader.MAX_COUNT_BONES too!
const int MAX_COUNT_BONES = 32;

uniform mat4 MVP; 
uniform mat4 CurrentTransforms[MAX_COUNT_BONES];


attribute vec3 a_position;
attribute vec2 a_texCoord;
attribute vec3 a_bones;
attribute vec3 a_weights;
// output parameters 
varying vec2 v_texCoord;

void main()
{
	v_texCoord = a_texCoord;
  
	vec4 totalLocalPos = vec4(0.0);
  
  if (int(a_bones.x) < MAX_COUNT_BONES)
  {
    totalLocalPos = (CurrentTransforms[int(a_bones.x)]*vec4(a_position, 1.0))*a_weights.x;
    if (int(a_bones.y) < MAX_COUNT_BONES)
    {
      totalLocalPos = totalLocalPos + (CurrentTransforms[int(a_bones.y)]*vec4(a_position, 1.0))*a_weights.y;
      if (int(a_bones.z) < MAX_COUNT_BONES)
      {
        totalLocalPos = totalLocalPos + (CurrentTransforms[int(a_bones.z)]*vec4(a_position, 1.0))*a_weights.z;
      }
    }
  } else
    totalLocalPos = vec4(a_position, 1.0);
  
  gl_Position = MVP * totalLocalPos;
}
