//
// Simple passthrough vertex shader
//
attribute vec3 in_Position;                  // (x,y,z)
attribute vec3 in_Normal;
attribute vec2 in_TextureCoord;              // (u,v)

varying vec3 v_Pos;

void main()
{
    gl_Position = gm_Matrices[MATRIX_PROJECTION] * vec4(mat3(gm_Matrices[MATRIX_VIEW]) * in_Position * 2., 1.);
    
    v_Pos = in_Position;
}
