//
// Simple passthrough vertex shader
//
attribute vec3 in_Position;                  // (x,y,z)
attribute vec2 in_TextureCoord;              // (u,v)

varying vec3 v_Pos;

void main()
{
	gl_Position.xy = in_TextureCoord * 2. - 1.;
	gl_Position.w = 1.;
    
    v_Pos = in_Position;
}
