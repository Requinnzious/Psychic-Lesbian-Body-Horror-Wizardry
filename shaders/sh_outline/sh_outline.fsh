//
// Simple passthrough fragment shader
//
varying vec2 v_vTexcoord;
varying vec4 v_vColour;

void main()
{
    vec4 finalColor = v_vColour * texture2D( gm_BaseTexture, v_vTexcoord );
	if (finalColor.rgb == vec3(0.)) discard;
	gl_FragColor = finalColor;
}
