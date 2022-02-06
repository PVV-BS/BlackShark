uniform mat4 MVP; 

attribute vec4 a_position;

//attribute vec2 a_surfacePosAttrib;

//varying vec2 v_surfacePosition;

void main() {

  //v_surfacePosition = a_surfacePosAttrib;
  gl_Position = MVP * a_position, 1.0;

}