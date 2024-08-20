/*////////////////////////////////////////////////////////////////////////
	SMF animation vertex shader
	This is the standard shader that comes with the SMF system.
	This does some basic diffuse, specular and rim lighting.
*/////////////////////////////////////////////////////////////////////////
attribute vec3 in_Position;                  // (x,y,z)
attribute vec3 in_Normal;                    // (x,y,z)
attribute vec2 in_TextureCoord;              // (u,v)
attribute vec4 in_Colour;                    // (r,g,b,a)
attribute vec4 in_Colour2;                   // (r,g,b,a)
attribute vec4 in_Colour3;                   // (r,g,b,a)

varying vec2 v_vTexcoord;
varying float v_vShade;
varying vec3 v_vViewSpacePos;
varying vec3 v_vViewSpaceNormal;
varying float v_vRimLightStrength;

uniform vec3 u_lightDir;

///////////////////////////////
/////Animation/////////////////
const int maxBones = 32;
uniform vec4 u_boneDQ[2*maxBones];
vec4 blendReal, blendDual;
vec3 blendTranslation;
void anim_init(ivec2 bone, vec2 weight)
{
	blendReal  =  u_boneDQ[bone[0]]   * weight[0] + u_boneDQ[bone[1]]   * weight[1];
	blendDual  =  u_boneDQ[bone[0]+1] * weight[0] + u_boneDQ[bone[1]+1] * weight[1];
	blendTranslation = 2. * (blendReal.w * blendDual.xyz - blendDual.w * blendReal.xyz + cross(blendReal.xyz, blendDual.xyz));
}
void anim_init(ivec4 bone, vec4 weight)
{
	blendReal  =  u_boneDQ[bone[0]]   * weight[0] + u_boneDQ[bone[1]]   * weight[1] + u_boneDQ[bone[2]]   * weight[2] + u_boneDQ[bone[3]]   * weight[3];
	blendDual  =  u_boneDQ[bone[0]+1] * weight[0] + u_boneDQ[bone[1]+1] * weight[1] + u_boneDQ[bone[2]+1] * weight[2] + u_boneDQ[bone[3]+1] * weight[3];
	//Normalize resulting dual quaternion
	float blendNormReal = 1.0 / length(blendReal);
	blendReal *= blendNormReal;
	blendDual = (blendDual - blendReal * dot(blendReal, blendDual)) * blendNormReal;
	blendTranslation = 2. * (blendReal.w * blendDual.xyz - blendDual.w * blendReal.xyz + cross(blendReal.xyz, blendDual.xyz));
}
vec3 anim_rotate(vec3 v)
{
	return v + 2. * cross(blendReal.xyz, cross(blendReal.xyz, v) + blendReal.w * v);
}
vec3 anim_transform(vec3 v)
{
	return anim_rotate(v) + blendTranslation;
}
/////Animation/////////////////
///////////////////////////////

void main()
{
	/*///////////////////////////////////////////////////////////////////////////////////////////
	Initialize the animation system, and transform the vertex position and normal
	/*///////////////////////////////////////////////////////////////////////////////////////////
	vec3 tangent = 2. * in_Colour.rgb - 1.; //This is not used for anything in this particular shader
	anim_init(ivec4(in_Colour2 * 510.0), in_Colour3);
	vec4 objectSpacePos = vec4(anim_transform(in_Position), 1.0);
	vec4 animNormal = vec4(anim_rotate(in_Normal), 0.);
	/////////////////////////////////////////////////////////////////////////////////////////////
	
	//Find the viewspace position
	vec4 viewSpacePos = gm_Matrices[MATRIX_WORLD_VIEW] * objectSpacePos;
	
	//Find the projection space coordinate
    gl_Position = gm_Matrices[MATRIX_PROJECTION] * viewSpacePos;
	
    v_vTexcoord = in_TextureCoord;
	
	//Find worldspace normal
	vec3 worldNormal = normalize((gm_Matrices[MATRIX_WORLD] * animNormal).xyz);
	
	//Simple directional lighting
	v_vShade = .5 + .49 * dot(worldNormal, u_lightDir);
	
	//Rim lighting
	mat4 V = gm_Matrices[MATRIX_VIEW];
	v_vViewSpacePos = viewSpacePos.xyz;
	v_vViewSpaceNormal = (V * vec4(worldNormal, 0.)).xyz;
	float dp = .5 - .5 * dot(u_lightDir, vec3(V[0].z, V[1].z, V[2].z));
	v_vRimLightStrength = mix(.4, 1., dp * dp * dp);
}