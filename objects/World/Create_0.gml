//This just stores the tilemap
tiles = [];
var meta = layer_tilemap_get_id("Meta");
for (var i = 0; i < room_width / 16; ++i) {
    array_push(tiles, []);
	for (var j = 0; j < room_height / 16; ++j) {
	    array_push(tiles[i], tilemap_get_at_pixel(meta, i * 16, j * 16))
	}
}

meshTileDim = 32;
cols = array_length(tiles);
rows = array_length(tiles[0]);


//Construct the mesh of the level
var uvs, nullUVs = sprite_get_uvs(sNull, 0);
var floorNorm = [0,0,1];

floorMesh = vertex_create_buffer();
wallMesh  = vertex_create_buffer();
vertex_begin(floorMesh, vFormat);
vertex_begin(wallMesh, vFormat);
for (var i = 0; i < cols; ++i) {
    for (var j = 0; j < rows; ++j) {
	    var tile = tiles[i][j];
		var spr = sNull;
		var zz  = 0;
		
		var nWall = false, sWall = false, eWall = false, wWall = false;
		
		//Get our sprite (temp)
		switch(tile) {
			case TileTypes.GRASS:
				spr = sGrassTexture;
				break;
			case TileTypes.TREE:
				spr = sGrassTexture;
				break;
			case TileTypes.PATH:
				spr = sPathTexture;
				break;
			case TileTypes.WALL:
				spr = sBrickTexture;
				zz  = meshTileDim;
				nWall = true;
				sWall = true;
				eWall = true;
				wWall = true;
				break;
		}
		
		//Get our uvs
		switch(tile) {
			case TileTypes.NULL:
				uvs = nullUVs;
				break;
			default:
				uvs = sprite_get_uvs(spr, irandom_range(0, sprite_get_number(spr) - 1));
				break;
		}
		
		//Make the floor tile
		var x1 = i * meshTileDim;
		var y1 = j * meshTileDim;
		var x2 = i * meshTileDim + meshTileDim;
		var y2 = j * meshTileDim + meshTileDim;
		
		addVertex(floorMesh, [x1, y1, zz], floorNorm, [uvs[0], uvs[1]], c_white, 1);
		addVertex(floorMesh, [x2, y1, zz], floorNorm, [uvs[2], uvs[1]], c_white, 1);
		addVertex(floorMesh, [x2, y2, zz], floorNorm, [uvs[2], uvs[3]], c_white, 1);
		
		addVertex(floorMesh, [x1, y1, zz], floorNorm, [uvs[0], uvs[1]], c_white, 1);
		addVertex(floorMesh, [x2, y2, zz], floorNorm, [uvs[2], uvs[3]], c_white, 1);
		addVertex(floorMesh, [x1, y2, zz], floorNorm, [uvs[0], uvs[3]], c_white, 1);
		
		//Make walls
		var norm;
		if(nWall) {
			norm = [0, -1, 0];
			addVertex(wallMesh, [x2, y1, zz],               norm, [uvs[0], uvs[1]], c_white, 1);
			addVertex(wallMesh, [x1, y1, zz],               norm, [uvs[2], uvs[1]], c_white, 1);
			addVertex(wallMesh, [x1, y1, zz - meshTileDim], norm, [uvs[2], uvs[3]], c_white, 1);
			
			addVertex(wallMesh, [x2, y1, zz],               norm, [uvs[0], uvs[1]], c_white, 1);
			addVertex(wallMesh, [x1, y1, zz - meshTileDim], norm, [uvs[2], uvs[3]], c_white, 1);
			addVertex(wallMesh, [x2, y1, zz - meshTileDim], norm, [uvs[0], uvs[3]], c_white, 1);
		}
		if(sWall) {
			norm = [0, 1, 0];
			addVertex(wallMesh, [x1, y2, zz],               norm, [uvs[0], uvs[1]], c_white, 1);
			addVertex(wallMesh, [x2, y2, zz],               norm, [uvs[2], uvs[1]], c_white, 1);
			addVertex(wallMesh, [x2, y2, zz - meshTileDim], norm, [uvs[2], uvs[3]], c_white, 1);
			
			addVertex(wallMesh, [x1, y2, zz],               norm, [uvs[0], uvs[1]], c_white, 1);
			addVertex(wallMesh, [x2, y2, zz - meshTileDim], norm, [uvs[2], uvs[3]], c_white, 1);
			addVertex(wallMesh, [x1, y2, zz - meshTileDim], norm, [uvs[0], uvs[3]], c_white, 1);
		}
		if(eWall) {
			norm = [1, 0, 0];
			addVertex(wallMesh, [x2, y2, zz],               norm, [uvs[0], uvs[1]], c_white, 1);
			addVertex(wallMesh, [x2, y1, zz],               norm, [uvs[2], uvs[1]], c_white, 1);
			addVertex(wallMesh, [x2, y1, zz - meshTileDim], norm, [uvs[2], uvs[3]], c_white, 1);
			
			addVertex(wallMesh, [x2, y2, zz],               norm, [uvs[0], uvs[1]], c_white, 1);
			addVertex(wallMesh, [x2, y1, zz - meshTileDim], norm, [uvs[2], uvs[3]], c_white, 1);
			addVertex(wallMesh, [x2, y2, zz - meshTileDim], norm, [uvs[0], uvs[3]], c_white, 1);
		}
		if(wWall) {
			norm = [-1, 0, 0];
			addVertex(wallMesh, [x1, y1, zz],               norm, [uvs[0], uvs[1]], c_white, 1);
			addVertex(wallMesh, [x1, y2, zz],               norm, [uvs[2], uvs[1]], c_white, 1);
			addVertex(wallMesh, [x1, y2, zz - meshTileDim], norm, [uvs[2], uvs[3]], c_white, 1);
			
			addVertex(wallMesh, [x1, y1, zz],               norm, [uvs[0], uvs[1]], c_white, 1);
			addVertex(wallMesh, [x1, y2, zz - meshTileDim], norm, [uvs[2], uvs[3]], c_white, 1);
			addVertex(wallMesh, [x1, y1, zz - meshTileDim], norm, [uvs[0], uvs[3]], c_white, 1);
		}
		
		
		if tile == TileTypes.TREE {
			uvs = sprite_get_uvs(sTreeTexture, 0);
			var xAvg = (x1 + x2) / 2;
			var yAvg = (y1 + y2) / 2;
			
			addVertex(wallMesh, [x1,   yAvg, zz + 96], [ 0, 1, 0], [uvs[0], uvs[1]], c_white, 1);
			addVertex(wallMesh, [x2,   yAvg, zz + 96], [ 0, 1, 0], [uvs[2], uvs[1]], c_white, 1);
			addVertex(wallMesh, [x2,   yAvg,      zz], [ 0, 1, 0], [uvs[2], uvs[3]], c_white, 1);

			addVertex(wallMesh, [x1,   yAvg, zz + 96], [ 0, 1, 0], [uvs[0], uvs[1]], c_white, 1);
			addVertex(wallMesh, [x2,   yAvg,      zz], [ 0, 1, 0], [uvs[2], uvs[3]], c_white, 1);
			addVertex(wallMesh, [x1,   yAvg,      zz], [ 0, 1, 0], [uvs[0], uvs[3]], c_white, 1);
			
			addVertex(wallMesh, [xAvg,   y1, zz + 96], [-1, 0, 0], [uvs[0], uvs[1]], c_white, 1);
			addVertex(wallMesh, [xAvg,   y2, zz + 96], [-1, 0, 0], [uvs[2], uvs[1]], c_white, 1);
			addVertex(wallMesh, [xAvg,   y2,      zz], [-1, 0, 0], [uvs[2], uvs[3]], c_white, 1);
			
			addVertex(wallMesh, [xAvg,   y1, zz + 96], [-1, 0, 0], [uvs[0], uvs[1]], c_white, 1);
			addVertex(wallMesh, [xAvg,   y2,      zz], [-1, 0, 0], [uvs[2], uvs[3]], c_white, 1);
			addVertex(wallMesh, [xAvg,   y1,      zz], [-1, 0, 0], [uvs[0], uvs[3]], c_white, 1);
		}
	}
}
vertex_end(floorMesh);
vertex_end(wallMesh);


identityMatrix = matrix_build( 0,   0, 0, 0, 0,  0,  1,  1,  1);
render = function() {
	matrix_set(matrix_world, identityMatrix);
	vertex_submit(floorMesh, pr_trianglelist, sprite_get_texture(sPathTexture, 0));
	vertex_submit(wallMesh, pr_trianglelist,  sprite_get_texture(sPathTexture, 0));
}

