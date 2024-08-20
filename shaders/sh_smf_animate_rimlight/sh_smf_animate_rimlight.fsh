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

uniform sampler2D u_lightLookup;
uniform float u_lightModifier;

void main()
{
    gl_FragColor =  texture2D(gm_BaseTexture, v_vTexcoord);
    //gl_FragColor =  vec4(.5, .5, .5, 1.);
	gl_FragColor.rgb *= u_lightModifier * texture2D(u_lightLookup, vec2(v_vShade, 0.)).rgb * 2.;
	
	float rimLight = pow(1. + dot(v_vViewSpaceNormal, normalize(v_vViewSpacePos)), 3.);
	rimLight *= v_vRimLightStrength;
	gl_FragColor.rgb += rimLight;
}
