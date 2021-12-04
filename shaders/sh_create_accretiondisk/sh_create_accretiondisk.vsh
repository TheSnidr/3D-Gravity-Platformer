//
// Simple passthrough vertex shader
//
attribute vec2 in_Position;                  // (x,y,z)

varying vec2 v_vTexcoord;

void main()
{
    gl_Position = vec4(in_Position, 1., 1.);
    
    v_vTexcoord = in_Position;
}
