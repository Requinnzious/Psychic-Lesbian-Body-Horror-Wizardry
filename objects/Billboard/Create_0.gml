z      = 0;
width  = TileDim;
height = TileDim;

buildMesh  = function() {
	var uvs  = sprite_get_uvs(sprite_index, image_index);
	
	mesh = vertex_create_buffer();
	vertex_begin(mesh, vFormat);
	
	addVertex(mesh, [-width/2, 0, height], [1, 1, 1], [uvs[0], uvs[1]], c_white, 1);
	addVertex(mesh, [ width/2, 0, height], [1, 1, 1], [uvs[2], uvs[1]], c_white, 1);
	addVertex(mesh, [ width/2, 0, 0],      [1, 1, 1], [uvs[2], uvs[3]], c_white, 1);
	addVertex(mesh, [-width/2, 0, height], [1, 1, 1], [uvs[0], uvs[1]], c_white, 1);
	addVertex(mesh, [ width/2, 0, 0],      [1, 1, 1], [uvs[2], uvs[3]], c_white, 1);
	addVertex(mesh, [-width/2, 0, 0],      [1, 1, 1], [uvs[0], uvs[3]], c_white, 1);

	vertex_end(mesh);
}

rebuildMesh = function() {
	vertex_delete_buffer(mesh);
	buildMesh();
}

render     = function() {
	if image_index + image_speed > image_number { instance_destroy(); return; };
	if floor(image_index - image_speed) < floor(image_index) rebuildMesh();
	matrix_set(matrix_world, matrix_build(x, y, z, 0, 0, Camera.lookDir + 90, 1, 1, 1))
	vertex_submit(mesh, pr_trianglelist, DefaultTexture);
}