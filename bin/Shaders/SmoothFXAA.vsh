precision mediump float;

//a resolution for our optimized shader
uniform vec2 Resolution;
uniform vec2 InvResolution;
attribute vec3 Position;

varying vec2 vUv;

//texcoords computed in vertex step
//to avoid dependent texture reads
varying vec2 v_rgbNW;
varying vec2 v_rgbNE;
varying vec2 v_rgbSW;
varying vec2 v_rgbSE;
varying vec2 v_rgbM;


void main() 
{
	gl_Position =  vec4(Position, 1);
   
	// compute the texture coords and send them to varyings
	vUv = (Position.xy + vec2(1.0, 1.0)) * 0.5;
	//vUv.y = 1.0 - vUv.y;
	vec2 fragCoord = vUv * Resolution;
	// To save 9 dependent texture reads, you can compute
	// these in the vertex shader and use the optimized
	// frag.glsl function in your frag shader. 
	// This is best suited for mobile devices, like iOS.
	v_rgbNW = (fragCoord + vec2(-1.0, -1.0)) * InvResolution;
	v_rgbNE = (fragCoord + vec2(1.0, -1.0)) * InvResolution;
	v_rgbSW = (fragCoord + vec2(-1.0, 1.0)) * InvResolution;
	v_rgbSE = (fragCoord + vec2(1.0, 1.0)) * InvResolution;
	v_rgbM = vec2(fragCoord * InvResolution);
}