//
// Simple passthrough vertex shader
//
attribute vec2 in_Position;                  // (x,y,z)

varying vec2 v_Pos;

void main()
{
    gl_Position = vec4(in_Position * 2. - 1., 1., 1.);
    
    v_Pos = vec2(in_Position.x, 1. - in_Position.y);
}
