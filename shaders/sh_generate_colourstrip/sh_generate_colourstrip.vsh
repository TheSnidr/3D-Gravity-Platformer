//
// Simple passthrough vertex shader
//
attribute vec3 in_Position;                  // (x,y,z)
varying float pos;

void main()
{
    gl_Position = vec4(in_Position.xy, 0., 1.);
	pos = in_Position.x * .5 + .5;
}
