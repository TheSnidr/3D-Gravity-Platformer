//
// Simple passthrough fragment shader
//
varying vec3 v_Pos;

uniform float u_time;
uniform float u_cells;
uniform float u_sparsity;
uniform float u_texelSize;
uniform vec3 u_invWorldSize;
uniform vec3 u_lightDir;
uniform vec3 u_sunColor;
uniform vec3 u_skyColBright;
uniform vec3 u_skyColDark;

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
float invCells = 1. / u_cells;
float timeAngle = TwoPI * u_time;
float readWorleyTexture(sampler2D tex, vec3 p, float blend)
{
	p *= u_invWorldSize;
	//Each layer has a one-pixel-wide padding around it, to avoid bleeding from surrounding layers:
	vec2 uv = u_texelSize * 1.5 + (invCells - 3. * u_texelSize) * fract(p.xy); 
	//Find the correct z-layer:
	uv += vec2(floor(mod(p.z, u_cells)), floor(p.z * invCells)) * invCells;
	vec4 col = texture2D(tex, uv);
	float worley1 = mix(col.r, col.g, fract(p.z)); //Blend between this layer and the layer above
	float worley2 = mix(col.b, col.a, fract(p.z)); //Blend between this layer and the layer above
	return mix(worley1, worley2, blend); //Blend between the two different worley noise textures
}

#define maxCloudIterations 6
float getCloudDensity(vec3 p, int iterations, float offset)
{
	float cloud = 0.;
	float weight = 1.;
	float weights = 0.;
	float scaleIncr = 2.2;
	float invScaleIncr = 1. / scaleIncr;
	float blendFactor = 2.;
	int i = 0;
	while (++i <= maxCloudIterations)
	{
		float blend = .5 + .5 * sin(offset + ceil(blendFactor) * timeAngle);
		cloud += weight * readWorleyTexture(gm_BaseTexture, p, blend);
		weights += weight;
		if (i > iterations){break;}
		p *= scaleIncr;
		weight *= invScaleIncr;
		blendFactor *= 1.8; //This cannot increase as quickly as the scale does, that would break the illusion of random movement
	}
	cloud *= u_sparsity / weights;
	return max(1. - cloud * cloud, 0.);
}

void main()
{
	vec3 pos = .5 + v_Pos * 2.5;
	float noise = hash3to1(pos * 100.);
	float blendOffset = TwoPI * readWorleyTexture(gm_BaseTexture, pos * .5, 0.); //Offset the blending with the help of worley noise for even more apparent randomness
	float cloudDensity = getCloudDensity(pos, 5, blendOffset);
	float lightDp = dot(u_lightDir, normalize(v_Pos));
	float cloudVisibility = min(cloudDensity * 6., .6 + .4 * cloudDensity);
	
	vec3 cloudCol = vec3(.6);
	
	//Shine through when looking towards the sun
	cloudCol += .5 * u_sunColor * max(1. - 3. * cloudDensity, 0.) * pow(max(-lightDp, 0.), 3.);
	
	//Shine onto normal
	cloudCol += (.15 + .8 * cloudDensity * cloudDensity) * u_sunColor * min(.8, .5 + .5 * lightDp);
	
	//Shine onto top of cloud
	float densityCheck = mix(cloudDensity, getCloudDensity(pos - u_lightDir * .1, 4, blendOffset), min(.8, 2. * (1. + lightDp)));
	cloudCol += u_sunColor * .8 * max(1. - 2. * densityCheck, 0.) * (.7 - lightDp * .3);
	
	//Add shadows underneath clouds
	cloudCol -= .2 * clamp(2. * (densityCheck - cloudDensity), 0., 1.) * (.6 - lightDp * .4);
	
	//Make the sky colour brighter the closer the pixel is to the light direction 
	float dp = max(0., - lightDp - 2. / 3.) * 3.;
	dp *= dp * dp * dp;
	vec3 skyCol = mix(u_skyColBright, u_sunColor, dp * dp + noise * .02); //Add noise to avoid banding
	skyCol = mix(skyCol, u_sunColor, step(lightDp, -.99)); //Draw circular uni-color sun in the middle
	float dark = clamp(lightDp + .35 + noise * .05, 0., 1.);
	skyCol = mix(skyCol, u_skyColDark, dark); //Add noise to avoid banding
	
	//Stars
	float blend = smoothstep(-1., 1., sin(blendOffset * 10. + 5. * timeAngle));
	float starDist = readWorleyTexture(gm_BaseTexture, pos * 13., blend);
	float d = max(0., 1.8 - 9. * starDist);
	vec3 starCol = min((1. + hsv2rgb(vec3(blendOffset * 10., 1., 1.))) * d * d * dark, 1.) * (1. - cloudVisibility);
	
	gl_FragColor = vec4(mix(skyCol + starCol, cloudCol, cloudVisibility), 1.);
}
