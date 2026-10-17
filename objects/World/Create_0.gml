identityMatrix = matrix_build( 0,   0, 0, 0, 0,  0,  1,  1,  1);

entities = ds_map_create();
entities[? SixOfCups.uuid] = SixOfCups;

dodecahedron = smf_model_load("dodecahedron.smf")
cube         = smf_model_load("cube.smf")
pyramid      = smf_model_load("pyramid.smf")
sphere       = smf_model_load("sphere.smf")

#region Store the tilemap
	tiles = [];
	meta  = layer_tilemap_get_id("Meta");
	coll  = layer_tilemap_get_id("Collisions");
	
	cols  = room_width  / TileDim;
	rows  = room_height / TileDim;
	
	aStar = mp_grid_create(0, 0, cols, rows, TileDim, TileDim);
	path  = path_add();
	
	for (var i = 0; i < cols; ++i) {
	    array_push(tiles, []);
		for (var j = 0; j < rows; ++j) {
			var _tile   = tilemap_get_at_pixel(meta, i * TileDim, j * TileDim);
			var _collis = tilemap_get_at_pixel(coll, i * TileDim, j * TileDim);
			var r = random_range(225, 255);
			var g = random_range(225, 255);
			var b = random_range(225, 255);
			var _color  = make_colour_rgb(r,g,b);
			
			var spr = sNull;
			switch(_tile) {
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
					break;
			}
			var tileVariation = irandom_range(0, sprite_get_number(spr) - 1)
			
		    array_push(tiles[i], {tile: _tile, collis: _collis, variation: tileVariation, color: _color});
			
			if _collis > 0 mp_grid_add_cell(aStar, i, j);
		}
	}
#endregion

#region Construct the mesh of the level
	meshDim     =    5;
	worldMeshes = [[]];
	for (var i = 0; i < cols / meshDim; ++i) {
	    for (var j = 0; j < rows / meshDim; ++j) {
			worldMeshes[i][j] = ds_map_create();
		}
	}


	buildMesh = function(meshes, meshX, meshY, initialize = false) {
		var uvs, nullUVs = sprite_get_uvs(sNull, 0);
		var floorNorm = [0,0,1];
		
		if meshX > array_length(worldMeshes) - 1 || meshY > array_length(worldMeshes[0]) - 1 return;
		
		//Draw meshes
		var meshW = meshX * meshDim + meshDim;
		var meshH = meshY * meshDim + meshDim;
		
		//Create all vertex buffers
		var numMeshes = array_length(meshes)
		for (var i = 0; i < numMeshes; ++i) {
			var meshName = meshes[i] + "Mesh";
			if worldMeshes[meshX][meshY][? meshName] vertex_delete_buffer(worldMeshes[meshX][meshY][? meshName]);
		    worldMeshes[meshX][meshY][? meshName]  = vertex_create_buffer();
			vertex_begin(  worldMeshes[meshX][meshY][? meshName], vFormat );
		}
		var wateruvs = sprite_get_uvs(sWaterTexture, 0/*irandom_range(0, sprite_get_number(spr) - 1)*/);
		var waterBackuvs = sprite_get_uvs(sWaterTexture_Back, 0/*irandom_range(0, sprite_get_number(spr) - 1)*/);
		for (var i = meshX * meshDim; i < meshW and i < array_length(World.tiles); ++i) {
		    for (var j = meshY * meshDim; j < meshH and j < array_length(World.tiles[0]); ++j) {				
				var tile   = tiles[i][j].tile;
				var coll   = tiles[i][j].collis;
				var vari   = tiles[i][j].variation;
				var color  = tiles[i][j].color;
				
				var spr = sNull;
				var norm;
				
				var x1 = i * TileDim;
				var y1 = j * TileDim;
				var x2 = i * TileDim + TileDim;
				var y2 = j * TileDim + TileDim;
				var zz = 0;
				var xAvg = (x1 + x2) / 2;
					
				for (var m = 0; m < numMeshes; ++m) {
					var mesh = meshes[m];
					var yAvg = (y1 + y2) / 2;
					
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
							zz  = TileDim * 1.5;
							nWall = true;
							sWall = true;
							eWall = true;
							wWall = true;
							break;
						case TileTypes.WATER:
							spr = sNull;
							zz  = -TileDim / 2;
							break;
					}
					
					//Get our uvs
					switch(tile) {
						case TileTypes.NULL:
							uvs = nullUVs;
							break;
						default:
							uvs = sprite_get_uvs(spr, vari/*irandom_range(0, sprite_get_number(spr) - 1)*/);
							break;
					}
		
					switch(mesh) {
						case "floor":
							addVertex(worldMeshes[meshX][meshY][? "floorMesh"], [x1, y1, zz], floorNorm, [uvs[0], uvs[1]], c_white, 1);
							addVertex(worldMeshes[meshX][meshY][? "floorMesh"], [x2, y1, zz], floorNorm, [uvs[2], uvs[1]], c_white, 1);
							addVertex(worldMeshes[meshX][meshY][? "floorMesh"], [x2, y2, zz], floorNorm, [uvs[2], uvs[3]], c_white, 1);
							addVertex(worldMeshes[meshX][meshY][? "floorMesh"], [x1, y1, zz], floorNorm, [uvs[0], uvs[1]], c_white, 1);
							addVertex(worldMeshes[meshX][meshY][? "floorMesh"], [x2, y2, zz], floorNorm, [uvs[2], uvs[3]], c_white, 1);
							addVertex(worldMeshes[meshX][meshY][? "floorMesh"], [x1, y2, zz], floorNorm, [uvs[0], uvs[3]], c_white, 1);
							
							
							if tile != TileTypes.WATER break;
							addVertex(worldMeshes[meshX][meshY][? "floorMesh"], [x1, y1, zz], floorNorm, [uvs[0], uvs[1]], c_white, 1);
							addVertex(worldMeshes[meshX][meshY][? "floorMesh"], [x2, y1, zz], floorNorm, [uvs[2], uvs[1]], c_white, 1);
							addVertex(worldMeshes[meshX][meshY][? "floorMesh"], [x2, y2, zz], floorNorm, [uvs[2], uvs[3]], c_white, 1);
							addVertex(worldMeshes[meshX][meshY][? "floorMesh"], [x1, y1, zz], floorNorm, [uvs[0], uvs[1]], c_white, 1);
							addVertex(worldMeshes[meshX][meshY][? "floorMesh"], [x2, y2, zz], floorNorm, [uvs[2], uvs[3]], c_white, 1);
							addVertex(worldMeshes[meshX][meshY][? "floorMesh"], [x1, y2, zz], floorNorm, [uvs[0], uvs[3]], c_white, 1);
							break;
							
						case "waterSurface":							
							if tile != TileTypes.WATER break;
							
							addVertex(worldMeshes[meshX][meshY][? "waterSurfaceMesh"], [x1, y1, zz + TileDim / 2 - 5.0], floorNorm, [0.0, 0.0], c_white, 1);
							addVertex(worldMeshes[meshX][meshY][? "waterSurfaceMesh"], [x2, y1, zz + TileDim / 2 - 5.0], floorNorm, [0.5, 0.0], c_white, 1);
							addVertex(worldMeshes[meshX][meshY][? "waterSurfaceMesh"], [x2, y2, zz + TileDim / 2 - 5.0], floorNorm, [0.5, 0.5], c_white, 1);
							addVertex(worldMeshes[meshX][meshY][? "waterSurfaceMesh"], [x1, y1, zz + TileDim / 2 - 5.0], floorNorm, [0.0, 0.0], c_white, 1);
							addVertex(worldMeshes[meshX][meshY][? "waterSurfaceMesh"], [x2, y2, zz + TileDim / 2 - 5.0], floorNorm, [0.5, 0.5], c_white, 1);
							addVertex(worldMeshes[meshX][meshY][? "waterSurfaceMesh"], [x1, y2, zz + TileDim / 2 - 5.0], floorNorm, [0.0, 0.5], c_white, 1);
							
							addVertex(worldMeshes[meshX][meshY][? "waterFoam1Mesh"],   [x1, y1, zz + TileDim / 2 - 5.5], floorNorm, [0.0, 0.0], c_white, 1);
							addVertex(worldMeshes[meshX][meshY][? "waterFoam1Mesh"],   [x2, y1, zz + TileDim / 2 - 5.5], floorNorm, [0.5, 0.0], c_white, 1);
							addVertex(worldMeshes[meshX][meshY][? "waterFoam1Mesh"],   [x2, y2, zz + TileDim / 2 - 5.5], floorNorm, [0.5, 0.5], c_white, 1);
							addVertex(worldMeshes[meshX][meshY][? "waterFoam1Mesh"],   [x1, y1, zz + TileDim / 2 - 5.5], floorNorm, [0.0, 0.0], c_white, 1);
							addVertex(worldMeshes[meshX][meshY][? "waterFoam1Mesh"],   [x2, y2, zz + TileDim / 2 - 5.5], floorNorm, [0.5, 0.5], c_white, 1);
							addVertex(worldMeshes[meshX][meshY][? "waterFoam1Mesh"],   [x1, y2, zz + TileDim / 2 - 5.5], floorNorm, [0.0, 0.5], c_white, 1);
							
							addVertex(worldMeshes[meshX][meshY][? "waterFoam2Mesh"],   [x1, y1, zz + TileDim / 2 - 6.0], floorNorm, [0.0, 0.0], c_white, 1);
							addVertex(worldMeshes[meshX][meshY][? "waterFoam2Mesh"],   [x2, y1, zz + TileDim / 2 - 6.0], floorNorm, [0.5, 0.0], c_white, 1);
							addVertex(worldMeshes[meshX][meshY][? "waterFoam2Mesh"],   [x2, y2, zz + TileDim / 2 - 6.0], floorNorm, [0.5, 0.5], c_white, 1);
							addVertex(worldMeshes[meshX][meshY][? "waterFoam2Mesh"],   [x1, y1, zz + TileDim / 2 - 6.0], floorNorm, [0.0, 0.0], c_white, 1);
							addVertex(worldMeshes[meshX][meshY][? "waterFoam2Mesh"],   [x2, y2, zz + TileDim / 2 - 6.0], floorNorm, [0.5, 0.5], c_white, 1);
							addVertex(worldMeshes[meshX][meshY][? "waterFoam2Mesh"],   [x1, y2, zz + TileDim / 2 - 6.0], floorNorm, [0.0, 0.5], c_white, 1);
							
							addVertex(worldMeshes[meshX][meshY][? "waterFoam3Mesh"],   [x1, y1, zz + TileDim / 2 - 7.5], floorNorm, [0.0, 0.0], c_white, 1);
							addVertex(worldMeshes[meshX][meshY][? "waterFoam3Mesh"],   [x2, y1, zz + TileDim / 2 - 7.5], floorNorm, [0.5, 0.0], c_white, 1);
							addVertex(worldMeshes[meshX][meshY][? "waterFoam3Mesh"],   [x2, y2, zz + TileDim / 2 - 7.5], floorNorm, [0.5, 0.5], c_white, 1);
							addVertex(worldMeshes[meshX][meshY][? "waterFoam3Mesh"],   [x1, y1, zz + TileDim / 2 - 7.5], floorNorm, [0.0, 0.0], c_white, 1);
							addVertex(worldMeshes[meshX][meshY][? "waterFoam3Mesh"],   [x2, y2, zz + TileDim / 2 - 7.5], floorNorm, [0.5, 0.5], c_white, 1);
							addVertex(worldMeshes[meshX][meshY][? "waterFoam3Mesh"],   [x1, y2, zz + TileDim / 2 - 7.5], floorNorm, [0.0, 0.5], c_white, 1);
							
							break;
					
						case "wall":
							//Make walls
							if(nWall) {
								norm = [0, -1, 0];
								addVertex(worldMeshes[meshX][meshY][? "wallMesh"], [x2, y1, zz],                 norm, [uvs[0], uvs[1]], color, 1);
								addVertex(worldMeshes[meshX][meshY][? "wallMesh"], [x1, y1, zz],                 norm, [uvs[2], uvs[1]], color, 1);
								addVertex(worldMeshes[meshX][meshY][? "wallMesh"], [x1, y1, zz - TileDim * 1.5], norm, [uvs[2], uvs[3]], color, 1);
								addVertex(worldMeshes[meshX][meshY][? "wallMesh"], [x2, y1, zz],                 norm, [uvs[0], uvs[1]], color, 1);
								addVertex(worldMeshes[meshX][meshY][? "wallMesh"], [x1, y1, zz - TileDim * 1.5], norm, [uvs[2], uvs[3]], color, 1);
								addVertex(worldMeshes[meshX][meshY][? "wallMesh"], [x2, y1, zz - TileDim * 1.5], norm, [uvs[0], uvs[3]], color, 1);
							}
							if(sWall) {
								norm = [0, 1, 0];
								addVertex(worldMeshes[meshX][meshY][? "wallMesh"], [x1, y2, zz],                 norm, [uvs[0], uvs[1]], color, 1);
								addVertex(worldMeshes[meshX][meshY][? "wallMesh"], [x2, y2, zz],                 norm, [uvs[2], uvs[1]], color, 1);
								addVertex(worldMeshes[meshX][meshY][? "wallMesh"], [x2, y2, zz - TileDim * 1.5], norm, [uvs[2], uvs[3]], color, 1);
								addVertex(worldMeshes[meshX][meshY][? "wallMesh"], [x1, y2, zz],                 norm, [uvs[0], uvs[1]], color, 1);
								addVertex(worldMeshes[meshX][meshY][? "wallMesh"], [x2, y2, zz - TileDim * 1.5], norm, [uvs[2], uvs[3]], color, 1);
								addVertex(worldMeshes[meshX][meshY][? "wallMesh"], [x1, y2, zz - TileDim * 1.5], norm, [uvs[0], uvs[3]], color, 1);
							}
							if(eWall) {
								norm = [1, 0, 0];
								addVertex(worldMeshes[meshX][meshY][? "wallMesh"], [x2, y2, zz],                 norm, [uvs[0], uvs[1]], color, 1);
								addVertex(worldMeshes[meshX][meshY][? "wallMesh"], [x2, y1, zz],                 norm, [uvs[2], uvs[1]], color, 1);
								addVertex(worldMeshes[meshX][meshY][? "wallMesh"], [x2, y1, zz - TileDim * 1.5], norm, [uvs[2], uvs[3]], color, 1);
								addVertex(worldMeshes[meshX][meshY][? "wallMesh"], [x2, y2, zz],                 norm, [uvs[0], uvs[1]], color, 1);
								addVertex(worldMeshes[meshX][meshY][? "wallMesh"], [x2, y1, zz - TileDim * 1.5], norm, [uvs[2], uvs[3]], color, 1);
								addVertex(worldMeshes[meshX][meshY][? "wallMesh"], [x2, y2, zz - TileDim * 1.5], norm, [uvs[0], uvs[3]], color, 1);
							}
							if(wWall) {
								norm = [-1, 0, 0];
								addVertex(worldMeshes[meshX][meshY][? "wallMesh"], [x1, y1, zz],                 norm, [uvs[0], uvs[1]], color, 1);
								addVertex(worldMeshes[meshX][meshY][? "wallMesh"], [x1, y2, zz],                 norm, [uvs[2], uvs[1]], color, 1);
								addVertex(worldMeshes[meshX][meshY][? "wallMesh"], [x1, y2, zz - TileDim * 1.5], norm, [uvs[2], uvs[3]], color, 1);
								addVertex(worldMeshes[meshX][meshY][? "wallMesh"], [x1, y1, zz],                 norm, [uvs[0], uvs[1]], color, 1);
								addVertex(worldMeshes[meshX][meshY][? "wallMesh"], [x1, y2, zz - TileDim * 1.5], norm, [uvs[2], uvs[3]], color, 1);
								addVertex(worldMeshes[meshX][meshY][? "wallMesh"], [x1, y1, zz - TileDim * 1.5], norm, [uvs[0], uvs[3]], color, 1);
							}
										
							//Mountains
							if tile == TileTypes.MOUNTAIN {
								uvs = sprite_get_uvs(sMountain, irandom(sprite_get_number(sMountain) - 1));
								var uAverage = (uvs[0] + uvs[2]) / 2;
								var vAverage = (uvs[1] + uvs[3]) / 2;
			
								addVertex(worldMeshes[meshX][meshY][? "wallMesh"], [xAvg, yAvg, 32], [  0,  .5, .5], [uAverage, vAverage], c_white, 1);
								addVertex(worldMeshes[meshX][meshY][? "wallMesh"], [x2,     y2,  0], [  0,  .5, .5], [uvs[2],     uvs[3]], c_white, 1);
								addVertex(worldMeshes[meshX][meshY][? "wallMesh"], [x1,     y2,  0], [  0,  .5, .5], [uvs[0],     uvs[3]], c_white, 1);
			
								addVertex(worldMeshes[meshX][meshY][? "wallMesh"], [xAvg, yAvg, 32], [-.5,   0, .5], [uAverage, vAverage], c_white, 1);
								addVertex(worldMeshes[meshX][meshY][? "wallMesh"], [x1,     y2,  0], [-.5,   0, .5], [uvs[2],     uvs[3]], c_white, 1);
								addVertex(worldMeshes[meshX][meshY][? "wallMesh"], [x1,     y1,  0], [-.5,   0, .5], [uvs[0],     uvs[3]], c_white, 1);
			
								addVertex(worldMeshes[meshX][meshY][? "wallMesh"], [xAvg, yAvg, 32], [  0, -.5, .5], [uAverage, vAverage], c_white, 1);
								addVertex(worldMeshes[meshX][meshY][? "wallMesh"], [x1,     y1,  0], [  0, -.5, .5], [uvs[2],     uvs[3]], c_white, 1);
								addVertex(worldMeshes[meshX][meshY][? "wallMesh"], [x2,     y1,  0], [  0, -.5, .5], [uvs[0],     uvs[3]], c_white, 1);
			
								addVertex(worldMeshes[meshX][meshY][? "wallMesh"], [xAvg, yAvg, 32], [ .5,   0, .5], [uAverage, vAverage], c_white, 1);
								addVertex(worldMeshes[meshX][meshY][? "wallMesh"], [x2,     y1,  0], [ .5,   0, .5], [uvs[2],     uvs[3]], c_white, 1);
								addVertex(worldMeshes[meshX][meshY][? "wallMesh"], [x2,     y2,  0], [ .5,   0, .5], [uvs[0],     uvs[3]], c_white, 1);
							}
							
							if tile != TileTypes.WATER break;
							
							
							if i > 0 and tiles[i - 1][j].tile != TileTypes.WATER {
								norm = [-1, 0, 0];
								addVertex(worldMeshes[meshX][meshY][? "wallMesh"], [x1, y1, zz + TileDim / 2], norm, [uvs[0], uvs[1]], color, 1);
								addVertex(worldMeshes[meshX][meshY][? "wallMesh"], [x1, y2, zz + TileDim / 2], norm, [uvs[2], uvs[1]], color, 1);
								addVertex(worldMeshes[meshX][meshY][? "wallMesh"], [x1, y2, zz],               norm, [uvs[2], uvs[3]], color, 1);
								addVertex(worldMeshes[meshX][meshY][? "wallMesh"], [x1, y1, zz + TileDim / 2], norm, [uvs[0], uvs[1]], color, 1);
								addVertex(worldMeshes[meshX][meshY][? "wallMesh"], [x1, y2, zz],               norm, [uvs[2], uvs[3]], color, 1);
								addVertex(worldMeshes[meshX][meshY][? "wallMesh"], [x1, y1, zz],               norm, [uvs[0], uvs[3]], color, 1);
							}							
							if i < array_length(tiles) - 1 and tiles[i + 1][j].tile != TileTypes.WATER {
								norm = [1, 0, 0];
								addVertex(worldMeshes[meshX][meshY][? "wallMesh"], [x2, y2, zz + TileDim / 2], norm, [uvs[0], uvs[1]], color, 1);
								addVertex(worldMeshes[meshX][meshY][? "wallMesh"], [x2, y1, zz + TileDim / 2], norm, [uvs[2], uvs[1]], color, 1);
								addVertex(worldMeshes[meshX][meshY][? "wallMesh"], [x2, y1, zz],               norm, [uvs[2], uvs[3]], color, 1);
								addVertex(worldMeshes[meshX][meshY][? "wallMesh"], [x2, y2, zz + TileDim / 2], norm, [uvs[0], uvs[1]], color, 1);
								addVertex(worldMeshes[meshX][meshY][? "wallMesh"], [x2, y1, zz],               norm, [uvs[2], uvs[3]], color, 1);
								addVertex(worldMeshes[meshX][meshY][? "wallMesh"], [x2, y2, zz],               norm, [uvs[0], uvs[3]], color, 1);
							}
							if j > 0 and tiles[i][j - 1].tile != TileTypes.WATER {
								norm = [0, -1, 0];
								addVertex(worldMeshes[meshX][meshY][? "wallMesh"], [x2, y1, zz + TileDim / 2], norm, [uvs[0], uvs[1]], color, 1);
								addVertex(worldMeshes[meshX][meshY][? "wallMesh"], [x1, y1, zz + TileDim / 2], norm, [uvs[2], uvs[1]], color, 1);
								addVertex(worldMeshes[meshX][meshY][? "wallMesh"], [x1, y1, zz],               norm, [uvs[2], uvs[3]], color, 1);
								addVertex(worldMeshes[meshX][meshY][? "wallMesh"], [x2, y1, zz + TileDim / 2], norm, [uvs[0], uvs[1]], color, 1);
								addVertex(worldMeshes[meshX][meshY][? "wallMesh"], [x1, y1, zz],               norm, [uvs[2], uvs[3]], color, 1);
								addVertex(worldMeshes[meshX][meshY][? "wallMesh"], [x2, y1, zz],               norm, [uvs[0], uvs[3]], color, 1);
							}							
							if j < array_length(tiles[0]) - 1 and tiles[i][j + 1].tile != TileTypes.WATER {
								norm = [0, 1, 0];
								addVertex(worldMeshes[meshX][meshY][? "wallMesh"], [x1, y2, zz + TileDim / 2], norm, [uvs[0], uvs[1]], color, 1);
								addVertex(worldMeshes[meshX][meshY][? "wallMesh"], [x2, y2, zz + TileDim / 2], norm, [uvs[2], uvs[1]], color, 1);
								addVertex(worldMeshes[meshX][meshY][? "wallMesh"], [x2, y2, zz],               norm, [uvs[2], uvs[3]], color, 1);
								addVertex(worldMeshes[meshX][meshY][? "wallMesh"], [x1, y2, zz + TileDim / 2], norm, [uvs[0], uvs[1]], color, 1);
								addVertex(worldMeshes[meshX][meshY][? "wallMesh"], [x2, y2, zz],               norm, [uvs[2], uvs[3]], color, 1);
								addVertex(worldMeshes[meshX][meshY][? "wallMesh"], [x1, y2, zz],               norm, [uvs[0], uvs[3]], color, 1);
							}
							break;
					
						case "canopy":
							if tile != TileTypes.TREE break;
							//Make small canopy
							uvs    = sprite_get_uvs(sCanopyTexture, irandom(sprite_get_number(sCanopyTexture) - 1));
							var width  = random_range(-16, 16) + sprite_get_width(sCanopyTexture);
							var height = random_range(-16, 16) + sprite_get_height(sCanopyTexture);
			
							var cx1 = xAvg - width  / 2;
							var cx2 = xAvg + width  / 2;
							var cy1 = yAvg - height / 2;
							var cy2 = yAvg + height / 2;
			
							var cz1 = random_range(48, 64);
							var cz2 = random_range(48, 64);
			
							addVertex(worldMeshes[meshX][meshY][? "canopyMesh"], [cx1, cy1, cz1], [0, 0, -1], [uvs[0], uvs[1]], c_white, 1);
							addVertex(worldMeshes[meshX][meshY][? "canopyMesh"], [cx2, cy1, cz1], [0, 0, -1], [uvs[2], uvs[1]], c_white, 1);
							addVertex(worldMeshes[meshX][meshY][? "canopyMesh"], [cx2, cy2, cz2], [0, 0, -1], [uvs[2], uvs[3]], c_white, 1);
							addVertex(worldMeshes[meshX][meshY][? "canopyMesh"], [cx1, cy1, cz1], [0, 0, -1], [uvs[0], uvs[1]], c_white, 1);
							addVertex(worldMeshes[meshX][meshY][? "canopyMesh"], [cx2, cy2, cz2], [0, 0, -1], [uvs[2], uvs[3]], c_white, 1);
							addVertex(worldMeshes[meshX][meshY][? "canopyMesh"], [cx1, cy2, cz2], [0, 0, -1], [uvs[0], uvs[3]], c_white, 1);
			
			
							//Make large canopy
							uvs = sprite_get_uvs(sCanopyTexture_1, irandom(sprite_get_number(sCanopyTexture_1)- 1));
							width  = random_range(-16, 16) + sprite_get_width(sCanopyTexture_1);
							height = random_range(-16, 16) + sprite_get_height(sCanopyTexture_1);
			
							cx1 = xAvg - width  / 2;
							cx2 = xAvg + width  / 2;
							cy1 = yAvg - height / 2;
							cy2 = yAvg + height / 2;
			
							cz1 = random_range(80, 96);
							cz2 = random_range(80, 96);
			
							addVertex(worldMeshes[meshX][meshY][? "canopyMesh"], [cx1, cy1, cz1], [0, 0, -1], [uvs[0], uvs[1]], c_white, 1);
							addVertex(worldMeshes[meshX][meshY][? "canopyMesh"], [cx2, cy1, cz1], [0, 0, -1], [uvs[2], uvs[1]], c_white, 1);
							addVertex(worldMeshes[meshX][meshY][? "canopyMesh"], [cx2, cy2, cz2], [0, 0, -1], [uvs[2], uvs[3]], c_white, 1);
							addVertex(worldMeshes[meshX][meshY][? "canopyMesh"], [cx1, cy1, cz1], [0, 0, -1], [uvs[0], uvs[1]], c_white, 1);
							addVertex(worldMeshes[meshX][meshY][? "canopyMesh"], [cx2, cy2, cz2], [0, 0, -1], [uvs[2], uvs[3]], c_white, 1);
							addVertex(worldMeshes[meshX][meshY][? "canopyMesh"], [cx1, cy2, cz2], [0, 0, -1], [uvs[0], uvs[3]], c_white, 1);
			
			
							//South wall
							addVertex(worldMeshes[meshX][meshY][? "canopyMesh"], [cx1, cy2, cz1 + height], [0, 1, 0], [uvs[0], uvs[1]], c_white, 1);
							addVertex(worldMeshes[meshX][meshY][? "canopyMesh"], [cx2, cy2, cz1 + height], [0, 1, 0], [uvs[2], uvs[1]], c_white, 1);
							addVertex(worldMeshes[meshX][meshY][? "canopyMesh"], [cx2, cy2,         cz2], [0, 1, 0], [uvs[2], uvs[3]], c_white, 1);
							addVertex(worldMeshes[meshX][meshY][? "canopyMesh"], [cx1, cy2, cz1 + height], [0, 1, 0], [uvs[0], uvs[1]], c_white, 1);
							addVertex(worldMeshes[meshX][meshY][? "canopyMesh"], [cx2, cy2,          cz2], [0, 1, 0], [uvs[2], uvs[3]], c_white, 1);
							addVertex(worldMeshes[meshX][meshY][? "canopyMesh"], [cx1, cy2,          cz2], [0, 1, 0], [uvs[0], uvs[3]], c_white, 1);
							if random(1) < .15 {
								var foliageUVs = sprite_get_uvs(sFoliage, irandom(sprite_get_number(sFoliage) - 1));
								var fx1 = x1  + irandom(width - sprite_get_width(sFoliage));
								var fx2 = fx1 + sprite_get_width(sFoliage);
								var foliageHeight = sprite_get_height(sFoliage)
				
								addVertex(worldMeshes[meshX][meshY][? "canopyMesh"], [fx1, cy2, cz1],                 [0, 1, 0], [foliageUVs[0], foliageUVs[1]], c_white, 1);
								addVertex(worldMeshes[meshX][meshY][? "canopyMesh"], [fx2, cy2, cz1],                 [0, 1, 0], [foliageUVs[2], foliageUVs[1]], c_white, 1);
								addVertex(worldMeshes[meshX][meshY][? "canopyMesh"], [fx2, cy2, cz1 - foliageHeight], [0, 1, 0], [foliageUVs[2], foliageUVs[3]], c_white, 1);
								addVertex(worldMeshes[meshX][meshY][? "canopyMesh"], [fx1, cy2, cz1],                 [0, 1, 0], [foliageUVs[0], foliageUVs[1]], c_white, 1);
								addVertex(worldMeshes[meshX][meshY][? "canopyMesh"], [fx2, cy2, cz1 - foliageHeight], [0, 1, 0], [foliageUVs[2], foliageUVs[3]], c_white, 1);
								addVertex(worldMeshes[meshX][meshY][? "canopyMesh"], [fx1, cy2, cz1 - foliageHeight], [0, 1, 0], [foliageUVs[0], foliageUVs[3]], c_white, 1);
							}
			
							//North wall
							addVertex(worldMeshes[meshX][meshY][? "canopyMesh"], [cx2, cy1, cz1 + height], [0,-1, 0], [uvs[0], uvs[1]], c_white, 1);
							addVertex(worldMeshes[meshX][meshY][? "canopyMesh"], [cx1, cy1, cz1 + height], [0,-1, 0], [uvs[2], uvs[1]], c_white, 1);
							addVertex(worldMeshes[meshX][meshY][? "canopyMesh"], [cx1, cy1,          cz2], [0,-1, 0], [uvs[2], uvs[3]], c_white, 1);
							addVertex(worldMeshes[meshX][meshY][? "canopyMesh"], [cx2, cy1, cz1 + height], [0,-1, 0], [uvs[0], uvs[1]], c_white, 1);
							addVertex(worldMeshes[meshX][meshY][? "canopyMesh"], [cx1, cy1,          cz2], [0,-1, 0], [uvs[2], uvs[3]], c_white, 1);
							addVertex(worldMeshes[meshX][meshY][? "canopyMesh"], [cx2, cy1,          cz2], [0,-1, 0], [uvs[0], uvs[3]], c_white, 1);
							if random(1) < .15 {
								var foliageUVs = sprite_get_uvs(sFoliage, irandom(sprite_get_number(sFoliage) - 1));
								var fx1 = x2  - irandom(width - sprite_get_width(sFoliage));
								var fx2 = fx1 - sprite_get_width(sFoliage);
								var foliageHeight = sprite_get_height(sFoliage)
				
								addVertex(worldMeshes[meshX][meshY][? "canopyMesh"], [fx2, cy1, cz1],                 [0, -1, 0], [foliageUVs[0], foliageUVs[1]], c_white, 1);
								addVertex(worldMeshes[meshX][meshY][? "canopyMesh"], [fx1, cy1, cz1],                 [0, -1, 0], [foliageUVs[2], foliageUVs[1]], c_white, 1);
								addVertex(worldMeshes[meshX][meshY][? "canopyMesh"], [fx1, cy1, cz1 - foliageHeight], [0, -1, 0], [foliageUVs[2], foliageUVs[3]], c_white, 1);
								addVertex(worldMeshes[meshX][meshY][? "canopyMesh"], [fx2, cy1, cz1],                 [0, -1, 0], [foliageUVs[0], foliageUVs[1]], c_white, 1);
								addVertex(worldMeshes[meshX][meshY][? "canopyMesh"], [fx1, cy1, cz1 - foliageHeight], [0, -1, 0], [foliageUVs[2], foliageUVs[3]], c_white, 1);
								addVertex(worldMeshes[meshX][meshY][? "canopyMesh"], [fx2, cy1, cz1 - foliageHeight], [0, -1, 0], [foliageUVs[0], foliageUVs[3]], c_white, 1);
							}
			
							//East wall
							addVertex(worldMeshes[meshX][meshY][? "canopyMesh"], [cx2, cy2, cz1 + height], [1, 0, 0], [uvs[0], uvs[1]], c_white, 1);
							addVertex(worldMeshes[meshX][meshY][? "canopyMesh"], [cx2, cy1, cz1 + height], [1, 0, 0], [uvs[2], uvs[1]], c_white, 1);
							addVertex(worldMeshes[meshX][meshY][? "canopyMesh"], [cx2, cy1,          cz2], [1, 0, 0], [uvs[2], uvs[3]], c_white, 1);
							addVertex(worldMeshes[meshX][meshY][? "canopyMesh"], [cx2, cy2, cz1 + height], [1, 0, 0], [uvs[0], uvs[1]], c_white, 1);
							addVertex(worldMeshes[meshX][meshY][? "canopyMesh"], [cx2, cy1,          cz2], [1, 0, 0], [uvs[2], uvs[3]], c_white, 1);
							addVertex(worldMeshes[meshX][meshY][? "canopyMesh"], [cx2, cy2,          cz2], [1, 0, 0], [uvs[0], uvs[3]], c_white, 1);
							if random(1) < .15 {
								var foliageUVs = sprite_get_uvs(sFoliage, irandom(sprite_get_number(sFoliage) - 1));
								var fy1 = y2  - irandom(width - sprite_get_width(sFoliage));
								var fy2 = fy1 - sprite_get_width(sFoliage);
								var foliageHeight = sprite_get_height(sFoliage)
				
								addVertex(worldMeshes[meshX][meshY][? "canopyMesh"], [cx2, fy2, cz1],                 [-1, 0, 0], [foliageUVs[0], foliageUVs[1]], c_white, 1);
								addVertex(worldMeshes[meshX][meshY][? "canopyMesh"], [cx2, fy1, cz1],                 [-1, 0, 0], [foliageUVs[2], foliageUVs[1]], c_white, 1);
								addVertex(worldMeshes[meshX][meshY][? "canopyMesh"], [cx2, fy1, cz1 - foliageHeight], [-1, 0, 0], [foliageUVs[2], foliageUVs[3]], c_white, 1);
								addVertex(worldMeshes[meshX][meshY][? "canopyMesh"], [cx2, fy2, cz1],                 [-1, 0, 0], [foliageUVs[0], foliageUVs[1]], c_white, 1);
								addVertex(worldMeshes[meshX][meshY][? "canopyMesh"], [cx2, fy1, cz1 - foliageHeight], [-1, 0, 0], [foliageUVs[2], foliageUVs[3]], c_white, 1);
								addVertex(worldMeshes[meshX][meshY][? "canopyMesh"], [cx2, fy2, cz1 - foliageHeight], [-1, 0, 0], [foliageUVs[0], foliageUVs[3]], c_white, 1);
							}
			
							//west wall
							addVertex(worldMeshes[meshX][meshY][? "canopyMesh"], [cx1, cy1, cz1 + height], [-1, 0, 0], [uvs[0], uvs[1]], c_white, 1);
							addVertex(worldMeshes[meshX][meshY][? "canopyMesh"], [cx1, cy2, cz1 + height], [-1, 0, 0], [uvs[2], uvs[1]], c_white, 1);
							addVertex(worldMeshes[meshX][meshY][? "canopyMesh"], [cx1, cy2,          cz2], [-1, 0, 0], [uvs[2], uvs[3]], c_white, 1);
							addVertex(worldMeshes[meshX][meshY][? "canopyMesh"], [cx1, cy1, cz1 + height], [-1, 0, 0], [uvs[0], uvs[1]], c_white, 1);
							addVertex(worldMeshes[meshX][meshY][? "canopyMesh"], [cx1, cy2,         cz2], [-1, 0, 0], [uvs[2], uvs[3]], c_white, 1);
							addVertex(worldMeshes[meshX][meshY][? "canopyMesh"], [cx1, cy1,         cz2], [-1, 0, 0], [uvs[0], uvs[3]], c_white, 1);
							if random(1) < .15 {
								var foliageUVs = sprite_get_uvs(sFoliage, irandom(sprite_get_number(sFoliage) - 1));
								var fy1 = y1  + irandom(width - sprite_get_width(sFoliage));
								var fy2 = fy1 + sprite_get_width(sFoliage);
								var foliageHeight = sprite_get_height(sFoliage)
				
								addVertex(worldMeshes[meshX][meshY][? "canopyMesh"], [cx1, fy1, cz1],                 [-1, 0, 0], [foliageUVs[0], foliageUVs[1]], c_white, 1);
								addVertex(worldMeshes[meshX][meshY][? "canopyMesh"], [cx1, fy2, cz1],                 [-1, 0, 0], [foliageUVs[2], foliageUVs[1]], c_white, 1);
								addVertex(worldMeshes[meshX][meshY][? "canopyMesh"], [cx1, fy2, cz1 - foliageHeight], [-1, 0, 0], [foliageUVs[2], foliageUVs[3]], c_white, 1);
								addVertex(worldMeshes[meshX][meshY][? "canopyMesh"], [cx1, fy1, cz1],                 [-1, 0, 0], [foliageUVs[0], foliageUVs[1]], c_white, 1);
								addVertex(worldMeshes[meshX][meshY][? "canopyMesh"], [cx1, fy2, cz1 - foliageHeight], [-1, 0, 0], [foliageUVs[2], foliageUVs[3]], c_white, 1);
								addVertex(worldMeshes[meshX][meshY][? "canopyMesh"], [cx1, fy1, cz1 - foliageHeight], [-1, 0, 0], [foliageUVs[0], foliageUVs[3]], c_white, 1);
							}
							break;
					}
				}
				
				if !initialize continue;
				//Entities
				if tile == TileTypes.WALL {
					var _hp = 100;
					if coll == 2 {
						_hp = 1;
					}
					
					var deadColor = #ffaeae
					var _name = "Brick Wall"
					if coll == 2 _name = "Illusory Wall"
					var entity = new Entity(_name)
						.addComponent("Physics")
						.addComponent("Impassable",   {bumping: true})
						.addComponent("Health",       {hp: _hp, maxHP: _hp})
						.addComponent("Position",     {x: x1, y: y1, z: 0})
						.addComponent("Transform",    {x: 16, y: 16, z: 16})
						.addComponent("HealthColor",  {color: color, baseColor: color, deadColor: deadColor})
						.addComponent("WorldTile",    {gridX: x1/TileDim, gridY: y1/TileDim, tile: TileTypes.WALL, isBlocking: true, worldMeshes: ["floor", "wall"], color: color});

					if coll == 2 {
						entity.addComponent("DeathParticle", {sprite: sBrickTexture_Illusory})
							.addComponent("DeathSound",      {sound: SoundTypes.ILLUSION});
						entity.nameColor = "rainbow";
					} else {
						entity.addComponent("DamageSound", {sound: SoundTypes.HIT})
							.addComponent("DeathSound",      {sound: SoundTypes.GRASS});
						entity.nameColor = "c_gray";
					}

					entity.fireEvent(EntityCreateEvent);

					entities[? entity.uuid] = entity;
				}	
				if tile == TileTypes.GRASS {
					var entity = new Entity("Grass")
						.addComponent("Physics")
						.addComponent("Health",    {hp: 1})
						.addComponent("Position",  {x: x1, y: y1, z: 0})
						.addComponent("Transform", {x: 16, y: 16})
						.addComponent("Sprite",    {randomSubimage: true})
						.addComponent("HurtSprite")
						.addComponent("HurtColor")
						.addComponent("SteppedOn")
						.addComponent("DamageSound", {sound: SoundTypes.GRASS})
						.addComponent("WindShader")
						.addComponent("BillboardMesh")
						.addComponent("WorldTile", {gridX: x1/TileDim, gridY: y1/TileDim, tile: TileTypes.GRASS});

					entity.fireEvent(EntityCreateEvent);

					entities[? entity.uuid] = entity;
				}		
				if tile == TileTypes.TALLGRASS {
					var entity = new Entity("Tall Grass")
						.addComponent("Physics")
						.addComponent("Health",     {hp: 2})
						.addComponent("Position",   {x: x1, y: y1, z: 0})
						.addComponent("Transform",  {x: 16, y: 16})
						.addComponent("Sprite",     {sprite: sBBGrass_Tall, randomSubimage: true})
						.addComponent("SteppedOn",  {sprite: sBBGrass_Tall_Stepped})
						.addComponent("DamageSound", {sound: SoundTypes.GRASS})
						.addComponent("HurtSprite", {sprite: sBBGrass_Tall_Stepped})
						.addComponent("HurtColor")
						.addComponent("WindShader")
						.addComponent("BillboardMesh")
						.addComponent("WorldTile", {gridX: x1/TileDim, gridY: y1/TileDim, tile: TileTypes.TALLGRASS});

					entity.fireEvent(EntityCreateEvent);
					
					entities[? entity.uuid] = entity;
				}		
				if tile == TileTypes.FAIRYCIRCLE {
					var shrooms = 8;
					var theta   = 0;
					for (var k = 0; k < shrooms; ++k) {
						var shroomX = x1 + 16 + lengthdir_x(32, theta) + random_range(-2, 2);
						var shroomY = y1 + 16 + lengthdir_y(32, theta) + random_range(-2, 2);
				
						var entity = new Entity("Fairy Mushroom")
							.addComponent("Position",  {x: shroomX, y: shroomY, z: 0})
							.addComponent("Sprite",    {sprite: sBBShroom, randomSubimage: true})
							.addComponent("WindShader")
							.addComponent("BillboardMesh");

						entity.fireEvent(EntityCreateEvent);
				
						entities[? entity.uuid] = entity;
				
						theta += 360/shrooms;
					}
				}		
				if tile == TileTypes.TREE {
					var entity = new Entity("Tree")
						.addComponent("Physics")
						.addComponent("Health")
						.addComponent("Impassable",   {bumping: true})
						.addComponent("Position",  {x: x1, y: y1, z: 0})
						.addComponent("Transform", {x: TileDim / 2 + random_range(-2, 2), y: TileDim / 2 + random_range(-2, 2), z: 0})
						.addComponent("Sprite",    {sprite: sTreeTexture})
						.addComponent("WindShader")
						.addComponent("BillboardMesh")
						.addComponent("DamageSound", {sound: SoundTypes.HIT})
						.addComponent("WorldTile", {gridX: x1/TileDim, gridY: y1/TileDim, tile: TileTypes.WALL, isBlocking: true, worldMeshes: ["canopy"]});

					entity.fireEvent(EntityCreateEvent);

					entities[? entity.uuid] = entity;
				}
			}
		}
		
		//End drawing
		for (var i = 0; i < numMeshes; ++i) {
			var meshName = meshes[i] + "Mesh";
			vertex_end( worldMeshes[meshX][meshY][? meshName] );
		}
	}
	
	var meshes = ["floor", "wall", "canopy", "waterSurface", "waterDeep", "waterFoam1", "waterFoam2", "waterFoam3"];	
	for (var i = 0; i < array_length(worldMeshes); ++i) {
	    for (var j = 0; j < array_length(worldMeshes[0]); ++j) {
			buildMesh(meshes, i, j, true);
		}
	}
	
#endregion

#region World Methods
	render = function() {
		
		matrix_set(matrix_world, identityMatrix);
		
		for (var i = 0; i < array_length(worldMeshes); ++i) {
			for (var j = 0; j < array_length(worldMeshes[0]); ++j) {
				shader_set(shDefault);
					vertex_submit(worldMeshes[i][j][? "floorMesh"], pr_trianglelist, DefaultTexture);
					vertex_submit(worldMeshes[i][j][? "wallMesh"],  pr_trianglelist, DefaultTexture);
			}
		}
		for (var i = 0; i < array_length(worldMeshes); ++i) {
			for (var j = 0; j < array_length(worldMeshes[0]); ++j) {
				shader_set(shWind);
					vertex_submit(worldMeshes[i][j][? "canopyMesh"],       pr_trianglelist, DefaultTexture);
			}
		}
		for (var i = 0; i < array_length(worldMeshes); ++i) {
			for (var j = 0; j < array_length(worldMeshes[0]); ++j) {
				shader_set(shWater);	
					shader_set_uniform_f(shader_get_uniform(shWater, "windSpeed"), current_time/900);
					vertex_submit(worldMeshes[i][j][? "waterFoam3Mesh"], pr_trianglelist, sprite_get_texture(sWater2, 0));
					shader_set_uniform_f(shader_get_uniform(shWater, "windSpeed"), current_time/700);
					vertex_submit(worldMeshes[i][j][? "waterFoam2Mesh"], pr_trianglelist, sprite_get_texture(sWater1, 0));
					//shader_set_uniform_f(shader_get_uniform(shWater, "windSpeed"), current_time/500);
					//vertex_submit(worldMeshes[i][j][? "waterFoam1Mesh"], pr_trianglelist, sprite_get_texture(sWater, 0));
					shader_set_uniform_f(shader_get_uniform(shWater, "windSpeed"), current_time/1200);
					vertex_submit(worldMeshes[i][j][? "waterSurfaceMesh"], pr_trianglelist, sprite_get_texture(sWaterTexture, 0));
			}
		}
		
		shader_set(shDefault);
			with Decal       render();
			with Billboard   render();
			with WeaponSlash render();
		shader_reset();

		matrix_set(matrix_world, identityMatrix);
			with Mountain    render();

		EntityRenderEvent.fire();
		
		//Draw things that have outlines
		shader_set(sh_smf_static);
			surface_set_target_ext(0, Camera.screenSurf);
			surface_set_target_ext(1, Camera.normalSurf);
			surface_set_target_ext(2, Camera.depthSurf);
			
				//Devices?
				EntityRenderSMFEvent.fire();
				//with DeviceRenderer render(); 
				
			surface_reset_target();
		shader_reset();
	}
#endregion

#region Test Enemy
	var slimeX = 192;
	var slimeY = 448;
	var slimeZ =   0;

	//var slime = new Entity("Bite Slime")
	//	.addComponent("Physics",      {maxFlash:   24})
	//	.addComponent("Impassable",   {bumping: false})
	//	.addComponent("Health",       {hp: 12, deathTimer: 24})
	//	.addComponent("ShakeScreen",  {screenShake: 12, screenShakeIntensity: .1})
	//	.addComponent("Position",     {x: slimeX, y: slimeY, z: slimeZ})
	//	.addComponent("Transform",    {x: 16,  y: 16})
	//	.addComponent("Sprite",       {sprite: sSlime})
	//	.addComponent("HurtSubimage", {hurtTimer: 24, subimage: 1})
	//	.addComponent("TauntSprite")		
	//	.addComponent("AttackSubimage")
	//	.addComponent("HurtColor",    {hurtTimer: 24})
	//	.addComponent("DefaultShader")
	//	.addComponent("BillboardMesh")
	//	
	//	.addComponent("MiniMapSprite")
	//	.addComponent("DeathParticle")
	//	.addComponent("DamageSound")
	//	.addComponent("DeathSound")
	//	
	//	.addComponent("ExpDrop")
	//
	//var brain = instance_create_layer(slimeX, slimeY, "Instances", Brain, {parentEntity: slime});
	//
	//slime.fireEvent(EntityCreateEvent);
	//entities[? slime.uuid] = slime;
	//
	//slime.nameColor = "c_orange";
	
	
	var ibis = new Entity("Ibis")
		.addComponent("Physics",       {maxFlash:   24, hitDie: "1d4+1"})
		.addComponent("Impassable",    {bumping: false})
		.addComponent("Health",        {hp: 16, deathTimer: 24})
		.addComponent("ShakeScreen",   {screenShake: 12, screenShakeIntensity: .1})
		.addComponent("Position",      {x: slimeX, y: slimeY, z: slimeZ})
		.addComponent("Transform",     {x: 16,  y: 16, xScale: .5, yScale: .5, zScale: .5})
		.addComponent("DancingSprite", {sprite: sIbis_Dance})
		.addComponent("HurtSprite",    {sprite: sIbis_Hit, hurtTimer: 24})
		.addComponent("TauntSprite",   {sprite: sIbis_Taunt, loops: true, animSpeed: 3/60})
		.addComponent("AttackSprite",  {sprite: sIbis_Atk})
		.addComponent("HurtColor",     {hurtTimer: 24})
		.addComponent("DefaultShader")
		.addComponent("BillboardMesh")
		
		.addComponent("MiniMapSprite")
		.addComponent("DeathParticle")
		.addComponent("DamageSound")
		.addComponent("DeathSound")
		
		.addComponent("ExpDrop")

	var brain = instance_create_layer(slimeX, slimeY, "Instances", Brain, {parentEntity: ibis});

	ibis.fireEvent(EntityCreateEvent);
	entities[? ibis.uuid] = ibis;
	
	ibis.nameColor = "c_fuchsia";
	
	#region Slimes
		slimeX = 640;
		slimeY = 416;
		slimeZ =   0;

		slime = new Entity("Bite Slime")
			.addComponent("Physics",      {maxFlash:   24})
			.addComponent("Impassable",   {bumping: false})
			.addComponent("Health",       {hp: 12, deathTimer: 24})
			.addComponent("ShakeScreen",  {screenShake: 12, screenShakeIntensity: .1})
			.addComponent("Position",     {x: slimeX, y: slimeY, z: slimeZ})
			.addComponent("Transform",    {x: 16,  y: 16})
			.addComponent("Sprite",       {sprite: sSlime})
			.addComponent("HurtSubimage", {hurtTimer: 24, subimage: 1})
			.addComponent("TauntSprite")		
			.addComponent("AttackSubimage")
			.addComponent("HurtColor",    {hurtTimer: 24})
			.addComponent("DefaultShader")
			.addComponent("BillboardMesh")
		
			.addComponent("MiniMapSprite")
			.addComponent("DeathParticle")
			.addComponent("DamageSound")
			.addComponent("DeathSound")
		
			.addComponent("ExpDrop")

		brain = instance_create_layer(slimeX, slimeY, "Instances", Brain, {parentEntity: slime});

		slime.fireEvent(EntityCreateEvent);
		entities[? slime.uuid] = slime;
	
		slime.nameColor = "c_orange";
	
		slimeX = 1088;
		slimeY =  256;
		slimeZ =    0;

		slime = new Entity("Bite Slime")
			.addComponent("Physics",      {maxFlash:   24})
			.addComponent("Impassable",   {bumping: false})
			.addComponent("Health",       {hp: 12, deathTimer: 24})
			.addComponent("ShakeScreen",  {screenShake: 12, screenShakeIntensity: .1})
			.addComponent("Position",     {x: slimeX, y: slimeY, z: slimeZ})
			.addComponent("Transform",    {x: 16,  y: 16})
			.addComponent("Sprite",       {sprite: sSlime})
			.addComponent("HurtSubimage", {hurtTimer: 24, subimage: 1})
			.addComponent("TauntSprite")		
			.addComponent("AttackSubimage")
			.addComponent("HurtColor",    {hurtTimer: 24})
			.addComponent("DefaultShader")
			.addComponent("BillboardMesh")
		
			.addComponent("MiniMapSprite")
			.addComponent("DeathParticle")
			.addComponent("DamageSound")
			.addComponent("DeathSound")
		
			.addComponent("ExpDrop")

		brain = instance_create_layer(slimeX, slimeY, "Instances", Brain, {parentEntity: slime});

		slime.fireEvent(EntityCreateEvent);
		entities[? slime.uuid] = slime;
	
		slime.nameColor = "c_orange";
	
		slimeX = 1152;
		slimeY =  512;
		slimeZ =    0;

		slime = new Entity("Bite Slime")
			.addComponent("Physics",      {maxFlash:   24})
			.addComponent("Impassable",   {bumping: false})
			.addComponent("Health",       {hp: 12, deathTimer: 24})
			.addComponent("ShakeScreen",  {screenShake: 12, screenShakeIntensity: .1})
			.addComponent("Position",     {x: slimeX, y: slimeY, z: slimeZ})
			.addComponent("Transform",    {x: 16,  y: 16})
			.addComponent("Sprite",       {sprite: sSlime})
			.addComponent("HurtSubimage", {hurtTimer: 24, subimage: 1})
			.addComponent("TauntSprite")		
			.addComponent("AttackSubimage")
			.addComponent("HurtColor",    {hurtTimer: 24})
			.addComponent("DefaultShader")
			.addComponent("BillboardMesh")
		
			.addComponent("MiniMapSprite")
			.addComponent("DeathParticle")
			.addComponent("DamageSound")
			.addComponent("DeathSound")
		
			.addComponent("ExpDrop")

		brain = instance_create_layer(slimeX, slimeY, "Instances", Brain, {parentEntity: slime});

		slime.fireEvent(EntityCreateEvent);
		entities[? slime.uuid] = slime;
	
		slime.nameColor = "c_orange";
	#endregion
#endregion

var entity = new Entity("Potion")
	.addComponent("Health",    {hp: infinity})
	.addComponent("Position",  {x: 32, y: 32, z: 0})
	.addComponent("Transform", {
		x:       16, y:       16, z: function() { return 4 + sin(current_time / 1000) },
		xScale: .25, yScale: .25, zScale: .25
	})
	.addComponent("DefaultShader")
	.addComponent("BillboardLayers", { layers: [{sprite: sPotionBottle_1, color: c_white}, {sprite: sPotionFilling_1, color: c_silver}, {sprite: sPotion_1Effect_1, color: #ffff80}]})
entity.fireEvent(EntityCreateEvent);
entities[? entity.uuid] = entity;

// Polyhedral Devices
entity = new Entity("Dodecahedron")
	.addComponent("Health",    {hp: infinity})
	.addComponent("Position",  {x: 64, y: 64, z: 0})
	.addComponent("Transform", {
		x:        16, y:        16, z:         function() { return 8 + sin(current_time / 1000) },
		xScale:  2.5, yScale:  2.5, zScale:  2.5,
		xRotation: 0, yRotation: 0, zRotation: function() { return sin(current_time / 5000) * 360 }
	})
	.addComponent("SMFModel")
entity.fireEvent(EntityCreateEvent);
entities[? entity.uuid] = entity;
/*
entity = new Entity("Cube")
	.addComponent("Health",    {hp: infinity})
	.addComponent("Position",  {x: 96, y: 64, z: 0})
	.addComponent("Transform", {
		x:        16, y:        16, z:         function() { return 8 + sin(current_time / 1000) },
		xScale:  2.5, yScale:  2.5, zScale:  2.5,
		xRotation: 0, yRotation: 0, zRotation: function() { return sin(current_time / 5000) * 360 }
	})
	.addComponent("SMFModel",  {model: cube})
entity.fireEvent(EntityCreateEvent);
entities[? entity.uuid] = entity;

entity = new Entity("Pyramid")
	.addComponent("Health",    {hp: infinity})
	.addComponent("Position",  {x: 96, y: 96, z: 0})
	.addComponent("Transform", {
		x:        16, y:        16, z:         function() { return 8 + sin(current_time / 1000) },
		xScale:  2.5, yScale:  2.5, zScale:  2.5,
		xRotation: 0, yRotation: 0, zRotation: function() { return sin(current_time / 5000) * 360 }
	})
	.addComponent("SMFModel",  {model: pyramid})
entity.fireEvent(EntityCreateEvent);
entities[? entity.uuid] = entity;

entity = new Entity("Sphere")
	.addComponent("Health",    {hp: infinity})
	.addComponent("Position",  {x: 64, y: 96, z: 0})
	.addComponent("Transform", {
		x:        16, y:        16, z:         function() { return 8 + sin(current_time / 1000) },
		xScale:  3.5, yScale:  3.5, zScale:  3.5,
		xRotation: 0, yRotation: 0, zRotation: function() { return sin(current_time / 5000) * 360 }
	})
	.addComponent("SMFModel",  {model: sphere})
entity.fireEvent(EntityCreateEvent);
entities[? entity.uuid] = entity;