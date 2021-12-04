//
// Simple passthrough fragment shader
//
varying vec2 v_vTexcoord;

uniform float u_min;
uniform float u_alpha;

void main()
{
	float l = length(v_vTexcoord - .5) * 2.;
	float P = clamp(2. * abs(l - (1. + u_min) / 2.) / (1. - u_min), 0., 1.);
	
	P = 1. - P * P * P;
	
	float noise = .5 * texture2D(gm_BaseTexture, v_vTexcoord).r;
    gl_FragColor.rgb = 1. * (.5 + .5 * noise) * mix(noise, 1. + noise, P) * vec3(2.6, 1.5, 1.);
	P *= mix(noise, 1., P);
	gl_FragColor.rgb *= P;
	
	
	gl_FragColor.a = u_alpha;
}
