lookDir = 0;
z  = 0;
width  = TileDim / 4;
height = TileDim / 4;

createMesh = function() {
	norm = [0, 0, 0];

	switch(lookDir) {	
		case 90:
			x1 = x + irandom_range(width, width * 2);
			x2 = x1 + width;
			x3 = x2;
			x4 = x1;
		
			y1 = y + random(1);
			y2 = y1;
			y3 = y1;
			y4 = y1;
		
			z1 = z + irandom_range(height, height * 2);
			z2 = z1 + height;
		
			norm = [0, -1, 0];
		
			break;
	
		case 180: //case 0:
			x1 = x + random(1);
			x2 = x1;
			x3 = x1;
			x4 = x1;
		
			y1 = y + TileDim - irandom_range(width, width * 2);
			y2 = y1 - width;
			y3 = y2;
			y4 = y1;
		
			z1 = z + irandom_range(height, height * 2);
			z2 = z1 + height;
		
			norm = [1, 0, 0];
		
			break;
		
		case 270:
			x1 = x + TileDim - irandom_range(width, width * 2);
			x2 = x1 - width;
			x3 = x2;
			x4 = x1;
		
			y1 = y + TileDim - random(1);
			y2 = y1;
			y3 = y1;
			y4 = y1;
		
			z1 = z + irandom_range(height, height * 2);
			z2 = z1 + height;
		
			norm = [0, 1, 0];
		
			break;
	
		default: //case 0:
			x1 = x + TileDim - random(1);
			x2 = x1;
			x3 = x1;
			x4 = x1;
		
			y1 = y + irandom_range(width, width * 2);
			y2 = y1 + width;
			y3 = y2;
			y4 = y1;
		
			z1 = z + irandom_range(height, height * 2);
			z2 = z1 + height;
		
			norm = [-1, 0, 0];
			break;
		}
	
	buildMesh();
}

buildMesh  = function() {
	uvs  = sprite_get_uvs(sprite_index, image_index);
	mesh = vertex_create_buffer();
	vertex_begin(mesh, vFormat);
	
	addVertex(mesh, [x1, y1, z2], norm, [uvs[0], uvs[1]], c_white, 1);
	addVertex(mesh, [x2, y2, z2], norm, [uvs[2], uvs[1]], c_white, 1);
	addVertex(mesh, [x3, y3, z1], norm, [uvs[2], uvs[3]], c_white, 1);
	addVertex(mesh, [x1, y1, z2], norm, [uvs[0], uvs[1]], c_white, 1);
	addVertex(mesh, [x3, y3, z1], norm, [uvs[2], uvs[3]], c_white, 1);
	addVertex(mesh, [x4, y4, z1], norm, [uvs[0], uvs[3]], c_white, 1);

	vertex_end(mesh);
}

rebuildMesh = function() {
	vertex_delete_buffer(mesh);
	buildMesh();
}

render     = function() {
	if image_index + image_speed > image_number { instance_destroy(); return; };
	if floor(image_index - image_speed) < floor(image_index) rebuildMesh();
	vertex_submit(mesh, pr_trianglelist, DefaultTexture);
}