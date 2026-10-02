lookDir = 0;
z  = 0;
width  = World.meshTileDim / 4;
height = World.meshTileDim / 4;
image_index = irandom_range(0, image_number - 1);
image_speed = 0;

createMesh = function() {
	var uvs = sprite_get_uvs(sprite_index, image_index);

	var x1, x2, x3, x4;
	var y1, y2, y3, y4;
	var z1, z2;

	var norm = [0, 0, 0];

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
		
			y1 = y + World.meshTileDim - irandom_range(width, width * 2);
			y2 = y1 - width;
			y3 = y2;
			y4 = y1;
		
			z1 = z + irandom_range(height, height * 2);
			z2 = z1 + height;
			
			norm = [1, 0, 0];
			
			break;
			
		case 270:
			x1 = x + World.meshTileDim - irandom_range(width, width * 2);
			x2 = x1 - width;
			x3 = x2;
			x4 = x1;
		
			y1 = y + World.meshTileDim - random(1);
			y2 = y1;
			y3 = y1;
			y4 = y1;
		
			z1 = z + irandom_range(height, height * 2);
			z2 = z1 + height;
			
			norm = [0, 1, 0];
			
			break;
	
		default: //case 0:
			x1 = x + World.meshTileDim - random(1);
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
