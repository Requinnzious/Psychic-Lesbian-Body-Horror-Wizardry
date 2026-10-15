attribute vec3 in_Position;    
attribute vec3 in_Normal;      
attribute vec2 in_TextureCoord;
attribute vec4 in_Color;      

varying vec4 v_vColor;
varying vec2 v_vTexcoord;

uniform float windSpeed;
uniform float baseZ;

void main()
{
    vec4 object_space_pos = vec4( in_Position.x, in_Position.y, in_Position.z, 1.0);
	
	float baseZ = 0.;
	
	vec2 wind = vec2(0.);
	
	if(object_space_pos.z != baseZ) {
		wind            = vec2(sin(windSpeed + object_space_pos.x), cos(windSpeed + object_space_pos.y));
		object_space_pos.xy += wind;
		object_space_pos.z  -= clamp(wind, -1., 1.);
	}
    
    v_vColor    = in_Color;
    v_vTexcoord = in_TextureCoord + vec2(mod(windSpeed / 20., 0.5));
    gl_Position = gm_Matrices[MATRIX_WORLD_VIEW_PROJECTION] * object_space_pos;
}
