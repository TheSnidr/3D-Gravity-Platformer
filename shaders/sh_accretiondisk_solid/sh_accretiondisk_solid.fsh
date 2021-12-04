//
// Simple passthrough fragment shader
//
varying vec2 v_vTexcoord;

uniform float u_min;

void main()
{
	float l = length(v_vTexcoord - .5) * 2.;
	float P = clamp(2. * abs(l - (1. + u_min) / 2.) / (1. - u_min), 0., 1.);
	
	P = 1. - P * P;
	
	float noise = texture2D(gm_BaseTexture, v_vTexcoord).r;
	float val = smoothstep(0., .7, noise);
    gl_FragColor.rgb = vec3(val);
	P *= mix(noise, 1., P);
	
	gl_FragColor.a = P * (1. - val);
}
