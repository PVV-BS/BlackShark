// Pixel shader to generate the Depth Map
// Used for shadow mapping - generates depth map from the light's viewpoint precision highp float;
 
varying vec4 position; 
 
// taken from Fabien Sangalard's DEngine - this is used to pack the depth into a 32-bit texture (GL_RGBA)
vec4 pack (float depth)
{
    const vec4 bitSh = vec4(256.0 * 256.0 * 256.0,
                       256.0 * 256.0,
                       256.0,
                      1.0);
    const vec4 bitMsk = vec4(0,
                         1.0 / 256.0,
                         1.0 / 256.0,
                             1.0 / 256.0);
    vec4 comp = fract(depth * bitSh);
    comp -= comp.xxyz * bitMsk;
    return comp;
}
 
void main() 
{
    // the depth
    float normalizedDistance  = position.z / position.w;
        // scale it from 0-1
    normalizedDistance = (normalizedDistance + 1.0) / 2.0;
     
    // bias (to remove artifacts)
    normalizedDistance += 0.0005;
 
    // pack value into 32-bit RGBA texture
    gl_FragColor = pack(normalizedDistance);
     
}