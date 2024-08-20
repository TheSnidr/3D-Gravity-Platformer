//
// Simple passthrough vertex shader
//
attribute vec3 in_Position;                  // (x,y,z)
attribute vec3 in_Normal;
attribute vec2 in_TextureCoord;              // (u,v)


uniform vec3 u_lightDir;

varying vec3 v_Pos;
varying float v_skyFade;
varying vec2 v_vTexCoord;
varying vec3 v_lightDir;

void main()
{
	float far = gm_Matrices[MATRIX_PROJECTION][3].z / (1. - gm_Matrices[MATRIX_PROJECTION][2].z) - 10.;
    gl_Position = gm_Matrices[MATRIX_PROJECTION] * vec4(mat3(gm_Matrices[MATRIX_VIEW]) * in_Position * far, 1.);
	v_vTexCoord = in_TextureCoord;
    
    v_Pos = in_Position;
	v_lightDir = u_lightDir;
	v_skyFade = dot(vec3(gm_Matrices[MATRIX_VIEW][0].z, gm_Matrices[MATRIX_VIEW][1].z, gm_Matrices[MATRIX_VIEW][2].z), u_lightDir);
}
