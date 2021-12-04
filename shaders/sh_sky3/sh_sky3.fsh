//
// Simple passthrough fragment shader
//
varying vec3 v_Pos;
varying vec3 v_LookDir;
varying vec2 v_vTexCoord;

uniform float u_time;
uniform float u_cells;
uniform float u_sparsity;
uniform float u_texelSize;
uniform float u_texScale;
uniform vec3 u_invWorldSize;
uniform vec3 u_lightDir;
uniform vec3 u_sunColor;
uniform vec3 u_skyColBright;
uniform vec3 u_skyColDark;

uniform sampler2D u_noiseSampler;

#define TwoPI 6.28318531

vec3 hsv2rgb(vec3 c)
{
    const vec3 K = vec3(1.0, 2.0 / 3.0, 1.0 / 3.0);
    vec3 p = abs(fract(c.x + K) * 6.0 - 3.);
    return c.z * mix(K.xxx, clamp(p - 1., 0.0, 1.0), c.y);
}
float hash3to1(vec3 c) 
{
	//Hashing function that accepts a vec3 seed and returns a pseudorandom float
	return fract(512.0*fract(4096.0*sin(dot(c,vec3(17.0, 59.4, 29.0))))) - .5;
}
float timeAngle;
vec2 readWorleyTexture(sampler2D tex, vec3 p)
{
	p *= u_invWorldSize;
	//Each layer has a one-pixel-wide padding around it, to avoid bleeding from surrounding layers:
	vec2 uv = u_texelSize * 1.5 + (1. / u_cells - 3. * u_texelSize) * fract(p.xy); 
	//Find the correct z-layer:
	uv += floor(vec2(mod(p.z, u_cells), p.z / u_cells)) / u_cells;
	vec4 worleySample = texture2D(tex, uv);
	return mix(worleySample.rb, worleySample.ga, fract(p.z)); //Return both patterns as a vec2
}

vec2 getOctahedronCoord(vec3 p)
{
	//Find the quadrant of the vector
	vec2 s = sign(p.xy);
	//Push the vector out to the surface of the octahedron
	p /= dot(abs(p), vec3(1.));
	//Find unique texture coords of the given point on the octahedron
	vec2 T = p.xy + s * (1. - dot(s, p.xy)) * step(p.z, 0.);
	//Scale down slightly to avoid texel bleeding from opposite side of texture
	return T * u_texScale * .5 + .5;
}

const vec4 v0123 = vec4(0., 1., 2., 3.);
const vec4 v1 = vec4(1.);
vec4 expGetWeights(float t, float spread)
{
	//Creates a vec4 that weights four different values placed at 0, 1, 2 and 3 based on a bell curve
	//t should go between 0 and 4. The result is normalized so that the sum is 1.
	vec4 a = abs(v0123 - mod(t, 4.));
	a -= 4. * step(2., a);
	a = exp(- spread * a * a);
	return a / dot(a, v1);
}

float getCloudDensity(float noiseValue, float sparsity, vec3 p, float blendOffset, float worley)
{
	float weight = .1;
	float cloud = (noiseValue * noiseValue * sparsity + weight * worley) / (1. + weight);
	return max(1. - cloud * cloud, 0.);
}

void main()
{
	vec3 pos			= normalize(v_Pos);
	vec3 rayPos			= pos - u_lightDir * .05;
	vec4 noiseSample	= texture2D(gm_BaseTexture, v_vTexCoord);
	vec4 raySample		= texture2D(gm_BaseTexture, getOctahedronCoord(rayPos));
	vec2 worleySample	= readWorleyTexture(u_noiseSampler, pos * 70. + .5);
	float timeAngle		= TwoPI * u_time;
	float noise			= hash3to1(pos * 100.);
	float lightDp		= dot(u_lightDir, pos);
	float skyFade		= dot(v_LookDir, u_lightDir);
	float sparsity		= u_sparsity * max(1., 1. + lightDp);
	float blendOffset	= dot(noiseSample, vec4(1., 1., -.5, -1.)) * 3.;
	float dark			= clamp(lightDp * .5 + skyFade * 2. + .35 + noise * .05, 0., 1.);
	
	//Create clouds
	float smallClouds	= mix(worleySample.x, worleySample.y, .5 + .5 * sin(blendOffset * 10. + 30. * timeAngle));
	vec4  cloudWeights	= expGetWeights(blendOffset + u_time * 4., 2.);
	float cloudDensity	= getCloudDensity(dot(noiseSample, cloudWeights), sparsity, pos,	blendOffset, smallClouds);
	float rayDensity	= getCloudDensity(dot(raySample,   cloudWeights), sparsity, rayPos,	blendOffset, smallClouds);
	float cloudVis		= min(cloudDensity * 6., .6 + .4 * cloudDensity);
	float brightness	= .5 - .5 * skyFade;
	vec3  cloudCol		= vec3(.7 + (1. - brightness * brightness) * .2 + dark * .4);							//Make clouds brighter if we look away from the sun
	cloudCol			+= (.15 + .9 * cloudDensity * cloudDensity) * u_sunColor * min(.8, .5 + .5 * lightDp);	//Shine onto cloud normal
	cloudCol			+= u_sunColor * max(1. - 1.8 * rayDensity, 0.) * max(0., .2 - lightDp * .9);			//Shine onto top of cloud, depending on the density at an offset position
	cloudCol			-= .1 * clamp(2. * (rayDensity - cloudDensity) / cloudDensity, 0., 1.);					//Add shadows beneath clouds
	
	//Nebulae
	vec3 nebulablend	= .5 + .5 * sin(vec3(3.0, 2.5, 0.9) * blendOffset + 5. * timeAngle);
	vec3 nebulaSample	= noiseSample.rgb + (worleySample.x - worleySample.y) * .01;
	vec3 nebula1		= pow(noiseSample.a * nebulaSample * dot(nebulaSample, vec3(1.)), vec3(5.));
	vec3 nebula2		= pow((1. - noiseSample.a) * (1. - nebulaSample) * dot(1. - nebulaSample, vec3(1.)), vec3(5.));
	vec3 nebula			= mix(nebula1, nebula2, nebulablend);
	nebula				+= .15 * max(nebula.r, max(nebula.g, nebula.b));
	vec3 darkCol		= mix(u_skyColDark, nebula, .2 + .6 * max(0., skyFade));
	
	//Stars
	float starBlend		= .5 + .4 * sin(blendOffset * 10. + 5. * timeAngle);
	float starSample	= max(noiseSample.r, max(noiseSample.g, noiseSample.b)) * max(0., 1. - 4.5 * mix(worleySample.x, worleySample.y, starBlend));
	darkCol				+= 15. * min((.7 + hsv2rgb(vec3(blendOffset * 10., 1., 1.))) * starSample * starSample * dark, 1.) * (1. - cloudVis);
	
	//Find blue background colour of bright side of skybox
	vec3 skyCol = mix(u_skyColDark, u_skyColBright, clamp(.5 - .5 * lightDp - skyFade * .3 + noise * .005, 0., 1.));
	//Draw sun as a bright circle
	skyCol		= mix(skyCol, u_sunColor, min(1., pow(max(0., - lightDp - 2. / 3.) * 3., 6.) + noise * .02));
	//Mix in the dark side of the skybox
	skyCol		= mix(skyCol, darkCol, dark + noise * .01);
	//Draw clouds
	skyCol		= mix(skyCol, cloudCol, cloudVis + noise * .02);
	
	gl_FragColor = vec4(skyCol, 1.);
	
}
