varying vec4 v_vColor;
varying vec2 v_vTexcoord;

void main()
{
	vec4 finalColor =  v_vColor * texture2D( gm_BaseTexture, v_vTexcoord );
	if(finalColor.a < 0.05) discard;
    gl_FragColor = finalColor;
}
