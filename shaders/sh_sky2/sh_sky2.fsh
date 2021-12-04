//
// Simple passthrough fragment shader
//
varying vec3 v_Pos;

uniform float u_cells;
uniform float u_sparsity;
uniform float u_texelSize;
uniform vec3 u_invWorldSize;

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

#define maxCloudIterations 7
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
		float blend = .5 + .5 * sin(blendFactor);
		cloud += weight * readWorleyTexture(gm_BaseTexture, p, blend);
		weights += weight;
		if (i > iterations){break;}
		p *= scaleIncr;
		weight *= invScaleIncr;
		blendFactor *= 1.5;
	}
	return cloud / weights;
}
mat3 rotationMatrix(vec3 axis, float angle)
{
    axis = normalize(axis);
    float s = sin(angle);
    float c = cos(angle);
    float oc = 1.0 - c;
    
    return mat3(oc * axis.x * axis.x + c,           oc * axis.x * axis.y - axis.z * s,  oc * axis.z * axis.x + axis.y * s,
                oc * axis.x * axis.y + axis.z * s,  oc * axis.y * axis.y + c,           oc * axis.y * axis.z - axis.x * s,
                oc * axis.z * axis.x - axis.y * s,  oc * axis.y * axis.z + axis.x * s,  oc * axis.z * axis.z + c);
}

void main()
{
	gl_FragColor = vec4(1.);
	
	vec3 pos = normalize(v_Pos) * 2.5;
	gl_FragColor.r = getCloudDensity(.5 + pos, 6, 0.);
	pos *= rotationMatrix(normalize(vec3(0., 1.2, 2.3)), .8);
	gl_FragColor.g = getCloudDensity(.5 - pos, 6, 1.);
	pos *= rotationMatrix(normalize(vec3(1., -1.2, 0.)), .8);
	gl_FragColor.b = getCloudDensity(.5 + pos * 1.6, 6, 0.);
	pos *= rotationMatrix(normalize(vec3(1., 0., -2.3)), .8);
	gl_FragColor.a = getCloudDensity(.5 - pos, 6, 1.);
}
