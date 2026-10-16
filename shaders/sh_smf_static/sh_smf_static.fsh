/*////////////////////////////////////////////////////////////////////////
	SMF static fragment shader
	This is the standard shader that comes with the SMF system.
	This does some basic diffuse, specular and rim lighting.
*/////////////////////////////////////////////////////////////////////////
varying vec2 v_vTexcoord;
varying vec3 v_eyeVec;
varying vec3 v_vNormal;
varying float v_vRim;

void main()
{
	gl_FragData[0] = vec4(0., 0., 0., 1.);
	
    gl_FragData[0] = texture2D(gm_BaseTexture, v_vTexcoord);
	
	//Diffuse shade
	gl_FragData[0].rgb *= .5 + .7 * max(dot(v_vNormal, normalize(vec3(1.))), 0.);
	
	//Normal Surface
	gl_FragData[1] = vec4(v_vNormal / 2. + vec3(.5), 1.);
	
	//Depth Surface
	gl_FragData[2] = vec4(v_vNormal / 2. + vec3(.5), 1.);
}








	
	
	//Specular highlights
	//gl_FragColor.rgb += .1 * pow(max(dot(normalize(reflect(v_eyeVec, v_vNormal)), normalize(vec3(1.))), 0.), 4.);
	
	//Rim lighting
	//gl_FragColor.rgb += .1 * vec3(pow(1. + v_vRim, 2.));