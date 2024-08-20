//
// Simple passthrough fragment shader
//
varying float pos;

#define MAXCOLOURS 8
uniform vec4 u_col[MAXCOLOURS];

void main()
{
	vec4 c1, c2, c3;
	float P;
	for (int i = 0; i < MAXCOLOURS; i ++)
	{
		c1 = u_col[(i > 0) ? i-1 : 0];
		c2 = u_col[i];
		c3 = u_col[(i < MAXCOLOURS - 1) ? i+1 : MAXCOLOURS - 1];
		if (pos >= (c1.w + c2.w) * .5 && pos < (c2.w + c3.w) * .5)
		{
			P = (pos * 2. - c1.w - c2.w) / (c3.w - c1.w);
			break;
		}
	}
	vec3 p1 = mix((c1.rgb + c2.rgb) * .5, c2.rgb, P);
	vec3 p2 = mix(c2.rgb, (c2.rgb + c3.rgb) * .5, P);
	vec3 col = mix(p1, p2, P);
	
    gl_FragColor = vec4(col * .5, 1.);
}
