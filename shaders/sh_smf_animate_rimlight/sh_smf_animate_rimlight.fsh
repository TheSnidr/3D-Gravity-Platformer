/*////////////////////////////////////////////////////////////////////////
	SMF animation fragment shader
	This is the standard shader that comes with the SMF system.
	This does some basic diffuse, specular and rim lighting.
*/////////////////////////////////////////////////////////////////////////

varying vec2 v_vTexcoord;
varying float v_vShade;
varying vec3 v_vViewSpacePos;
varying vec3 v_vViewSpaceNormal;
varying float v_vRimLightStrength;

void main()
{
    gl_FragColor = texture2D(gm_BaseTexture, v_vTexcoord);
	gl_FragColor.rgb *= v_vShade;
	
	float rimLight = pow(1. + dot(v_vViewSpaceNormal, normalize(v_vViewSpacePos)), 3.);
	rimLight *= v_vRimLightStrength;
	gl_FragColor.rgb += rimLight;
}
