z = 0;
mesh = -1;
type = "null";

createMesh = function() {
	mesh = vertex_create_buffer();
	vertex_begin(mesh, vFormat);
	var width  = sprite_get_width(sprite_index);
	var height = sprite_get_height(sprite_index);
	
	addVertex(mesh, [-width/2, 0, height], [0, 1, 0], [0, 0], c_white, 1);
	addVertex(mesh, [ width/2, 0, height], [0, 1, 0], [1, 0], c_white, 1);
	addVertex(mesh, [ width/2, 0,      0], [0, 1, 0], [1, 1], c_white, 1);
	
	addVertex(mesh, [-width/2, 0, height], [0, 1, 0], [0, 0], c_white, 1);
	addVertex(mesh, [ width/2, 0,      0], [0, 1, 0], [1, 1], c_white, 1);
	addVertex(mesh, [-width/2, 0,      0], [0, 1, 0], [0, 1], c_white, 1);
	vertex_end(mesh);
	
	vertex_freeze(mesh);
}

render = function() {
	var windSpeed = 500;
	
	if sprite_index == sBBGrass_Tall windSpeed = 350;
	
	shader_set(shWind);	
	shader_set_uniform_f(shader_get_uniform(shWind, "windSpeed"), current_time/windSpeed);
	shader_set_uniform_f(shader_get_uniform(shWind, "baseZ"), z);
	
	var tex = sprite_get_texture(sprite_index, image_index);
	var zRot = Camera.lookDir + Camera.lookDirOffset + 90;
	matrix_set(matrix_world, matrix_build(x, y, z, 0, 0, zRot, 1, 1, 1));
	vertex_submit(mesh, pr_trianglelist, tex);
	
	shader_reset();
}