z = 0;

width  = random_range(1280, 1920);
height = random_range(1280, 1920);

createMesh = function() {
	var x1 = x;
	var x2 = x1 +  width;
	var y1 = y;
	var y2 = y1 +  width;
	var z2 = z  + height;
	
	var xAvg = (x1 + x2) / 2;
	var yAvg = (y1 + y2) / 2;
	
	var uvs      = sprite_get_uvs(sMountain, irandom(sprite_get_number(sMountain) - 1));
	var uAverage = (uvs[0] + uvs[2]) / 2;
	var vAverage = (uvs[1] + uvs[3]) / 2;
	
	mesh = vertex_create_buffer();
	vertex_begin(mesh, vFormat);
	addVertex(mesh, [xAvg, yAvg, z2], [  0,  .5, .5], [uAverage, vAverage], c_white, 1);
	addVertex(mesh, [x2,     y2,  z], [  0,  .5, .5], [uvs[2],     uvs[3]], c_white, 1);
	addVertex(mesh, [x1,     y2,  z], [  0,  .5, .5], [uvs[0],     uvs[3]], c_white, 1);
	addVertex(mesh, [xAvg, yAvg, z2], [-.5,   0, .5], [uAverage, vAverage], c_white, 1);
	addVertex(mesh, [x1,     y2,  z], [-.5,   0, .5], [uvs[2],     uvs[3]], c_white, 1);
	addVertex(mesh, [x1,     y1,  z], [-.5,   0, .5], [uvs[0],     uvs[3]], c_white, 1);
	addVertex(mesh, [xAvg, yAvg, z2], [  0, -.5, .5], [uAverage, vAverage], c_white, 1);
	addVertex(mesh, [x1,     y1,  z], [  0, -.5, .5], [uvs[2],     uvs[3]], c_white, 1);
	addVertex(mesh, [x2,     y1,  z], [  0, -.5, .5], [uvs[0],     uvs[3]], c_white, 1);
	addVertex(mesh, [xAvg, yAvg, z2], [ .5,   0, .5], [uAverage, vAverage], c_white, 1);
	addVertex(mesh, [x2,     y1,  z], [ .5,   0, .5], [uvs[2],     uvs[3]], c_white, 1);
	addVertex(mesh, [x2,     y2,  z], [ .5,   0, .5], [uvs[0],     uvs[3]], c_white, 1);
	vertex_end(mesh);
	
	vertex_freeze(mesh);
}

tex = sprite_get_texture(sprite_index, image_index);

render = function() {
	vertex_submit(mesh, pr_trianglelist, tex)
}

createMesh();