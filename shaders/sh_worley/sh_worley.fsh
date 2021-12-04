//
// Simple passthrough fragment shader
//
varying vec2 v_Pos;

uniform float u_cells;
uniform float u_time;
uniform float u_worldSize;
uniform float u_texelSize;

vec3 hash3to2(vec3 c) 
{
	float j = 512.0*fract(4096.0*sin(dot(c,vec3(17.0, 59.4, 29.0))));
	vec3 r;
	r.z = fract(j);
	j *= .125;
	r.x = fract(j);
	j *= .125;
	r.y = fract(j);
	return r-0.5;
}

float smin(float a, float b, float k)
{
    float h = max(k - abs(a - b), 0.0) / k;
    return min(a, b) - h * h * k * .25;
}

float worley(vec3 p)
{
	p *= u_worldSize;
	float d = 1.;
	for (int xx = 0; xx < 5; xx ++)
	{
		for (int yy = 0; yy < 5; yy ++)
		{
			for (int zz = 0; zz < 5; zz ++)
			{
				vec3 cell = floor(p) - 2. + vec3(xx, yy, zz);
				vec3 cellPos = cell + .5 + 2. * hash3to2(mod(cell, u_worldSize));
				d = smin(d, mod(distance(p, cellPos), u_worldSize), .15);
			}
		}
	}
	return d;
}
vec3 getVec3FromUVs(vec2 UV)
{
	float tx = 2. * u_texelSize * u_cells;
	vec3 pos;
	pos.x = clamp(fract(UV.x * u_cells) * (1. + 2. * tx) - tx, 0., 1.);
	pos.y = clamp(fract(UV.y * u_cells) * (1. + 2. * tx) - tx, 0., 1.);
	pos.z = (floor(UV.x * u_cells) / u_cells + floor(UV.y * u_cells)) / u_cells;
	return pos;
}

void main()
{
	vec3 pos = getVec3FromUVs(v_Pos);
	gl_FragColor = vec4(
						worley(pos),													//Create this pixel's density
						worley(pos + vec3(0., 0., 1. / (u_cells * u_cells))),			//Density of the corresponding pixel on the next z-layer
						worley(pos + .5),												//Create another worley pattern in the blue channel
						worley(pos + .5 + vec3(0., 0., 1. / (u_cells * u_cells))));		//And the density of the corresponding pixel on the next z-layer in the second pattern
}
