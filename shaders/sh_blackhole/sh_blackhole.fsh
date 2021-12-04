//
// Simple passthrough fragment shader
//
varying vec2 v_vTexcoord;
varying vec3 v_vViewSpacePos;
varying vec3 v_vViewSpaceNormal;

void main()
{
	vec3 N = normalize(v_vViewSpaceNormal);
	float dp = - dot(N, v_vViewSpacePos);
	float offset = 2. * dp * dp * dp * dp * dp;
    gl_FragColor = texture2D( gm_BaseTexture, v_vTexcoord - offset * N.xy);
	
	
	float border = 1.;
	float borderThickness = .05;
	vec3 borderColor = vec3(1.4, 1.1, .8);
	
	gl_FragColor.rgb = mix(gl_FragColor.rgb, borderColor, smoothstep(border - borderThickness * 2., border, offset));
	gl_FragColor.rgb = mix(gl_FragColor.rgb, vec3(0.), smoothstep(border, border + borderThickness, offset));	
}
