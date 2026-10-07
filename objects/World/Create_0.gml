identityMatrix = matrix_build( 0,   0, 0, 0, 0,  0,  1,  1,  1);

entities = ds_map_create();
entities[? SixOfCups.uuid] = SixOfCups;

#region Store the tilemap
	tiles = [];
	var meta  = layer_tilemap_get_id("Meta");
	coll  = layer_tilemap_get_id("Collisions");
	for (var i = 0; i < room_width / 32; ++i) {
	    array_push(tiles, []);
		for (var j = 0; j < room_height / 32; ++j) {
			var _tile   = tilemap_get_at_pixel(meta, i * 32, j * 32);
		    array_push(tiles[i], {tile: _tile});
		}
	}
	cols = array_length(tiles);
	rows = array_length(tiles[0]);
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
		
		for (var i = meshX * meshDim; i < meshW and i < array_length(World.tiles); ++i) {
		    for (var j = meshY * meshDim; j < meshH and j < array_length(World.tiles[0]); ++j) {				
				var tile   = tiles[i][j].tile;
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
		
					switch(mesh) {
						case "floor":
							addVertex(worldMeshes[meshX][meshY][? "floorMesh"], [x1, y1, zz], floorNorm, [uvs[0], uvs[1]], c_white, 1);
							addVertex(worldMeshes[meshX][meshY][? "floorMesh"], [x2, y1, zz], floorNorm, [uvs[2], uvs[1]], c_white, 1);
							addVertex(worldMeshes[meshX][meshY][? "floorMesh"], [x2, y2, zz], floorNorm, [uvs[2], uvs[3]], c_white, 1);
							addVertex(worldMeshes[meshX][meshY][? "floorMesh"], [x1, y1, zz], floorNorm, [uvs[0], uvs[1]], c_white, 1);
							addVertex(worldMeshes[meshX][meshY][? "floorMesh"], [x2, y2, zz], floorNorm, [uvs[2], uvs[3]], c_white, 1);
							addVertex(worldMeshes[meshX][meshY][? "floorMesh"], [x1, y2, zz], floorNorm, [uvs[0], uvs[3]], c_white, 1);
							break;
					
						case "wall":
							//Make walls
							if(nWall) {
								norm = [0, -1, 0];
								addVertex(worldMeshes[meshX][meshY][? "wallMesh"], [x2, y1, zz],               norm, [uvs[0], uvs[1]], c_white, 1);
								addVertex(worldMeshes[meshX][meshY][? "wallMesh"], [x1, y1, zz],               norm, [uvs[2], uvs[1]], c_white, 1);
								addVertex(worldMeshes[meshX][meshY][? "wallMesh"], [x1, y1, zz - TileDim * 1.5], norm, [uvs[2], uvs[3]], c_white, 1);
								
								addVertex(worldMeshes[meshX][meshY][? "wallMesh"], [x2, y1, zz],               norm, [uvs[0], uvs[1]], c_white, 1);
								addVertex(worldMeshes[meshX][meshY][? "wallMesh"], [x1, y1, zz - TileDim * 1.5], norm, [uvs[2], uvs[3]], c_white, 1);
								addVertex(worldMeshes[meshX][meshY][? "wallMesh"], [x2, y1, zz - TileDim * 1.5], norm, [uvs[0], uvs[3]], c_white, 1);
							}
							if(sWall) {
								norm = [0, 1, 0];
								addVertex(worldMeshes[meshX][meshY][? "wallMesh"], [x1, y2, zz],               norm, [uvs[0], uvs[1]], c_white, 1);
								addVertex(worldMeshes[meshX][meshY][? "wallMesh"], [x2, y2, zz],               norm, [uvs[2], uvs[1]], c_white, 1);
								addVertex(worldMeshes[meshX][meshY][? "wallMesh"], [x2, y2, zz - TileDim * 1.5], norm, [uvs[2], uvs[3]], c_white, 1);
			
								addVertex(worldMeshes[meshX][meshY][? "wallMesh"], [x1, y2, zz],               norm, [uvs[0], uvs[1]], c_white, 1);
								addVertex(worldMeshes[meshX][meshY][? "wallMesh"], [x2, y2, zz - TileDim * 1.5], norm, [uvs[2], uvs[3]], c_white, 1);
								addVertex(worldMeshes[meshX][meshY][? "wallMesh"], [x1, y2, zz - TileDim * 1.5], norm, [uvs[0], uvs[3]], c_white, 1);
							}
							if(eWall) {
								norm = [1, 0, 0];
								addVertex(worldMeshes[meshX][meshY][? "wallMesh"], [x2, y2, zz],               norm, [uvs[0], uvs[1]], c_white, 1);
								addVertex(worldMeshes[meshX][meshY][? "wallMesh"], [x2, y1, zz],               norm, [uvs[2], uvs[1]], c_white, 1);
								addVertex(worldMeshes[meshX][meshY][? "wallMesh"], [x2, y1, zz - TileDim * 1.5], norm, [uvs[2], uvs[3]], c_white, 1);
			
								addVertex(worldMeshes[meshX][meshY][? "wallMesh"], [x2, y2, zz],               norm, [uvs[0], uvs[1]], c_white, 1);
								addVertex(worldMeshes[meshX][meshY][? "wallMesh"], [x2, y1, zz - TileDim * 1.5], norm, [uvs[2], uvs[3]], c_white, 1);
								addVertex(worldMeshes[meshX][meshY][? "wallMesh"], [x2, y2, zz - TileDim * 1.5], norm, [uvs[0], uvs[3]], c_white, 1);
							}
							if(wWall) {
								norm = [-1, 0, 0];
								addVertex(worldMeshes[meshX][meshY][? "wallMesh"], [x1, y1, zz],               norm, [uvs[0], uvs[1]], c_white, 1);
								addVertex(worldMeshes[meshX][meshY][? "wallMesh"], [x1, y2, zz],               norm, [uvs[2], uvs[1]], c_white, 1);
								addVertex(worldMeshes[meshX][meshY][? "wallMesh"], [x1, y2, zz - TileDim * 1.5], norm, [uvs[2], uvs[3]], c_white, 1);
			
								addVertex(worldMeshes[meshX][meshY][? "wallMesh"], [x1, y1, zz],               norm, [uvs[0], uvs[1]], c_white, 1);
								addVertex(worldMeshes[meshX][meshY][? "wallMesh"], [x1, y2, zz - TileDim * 1.5], norm, [uvs[2], uvs[3]], c_white, 1);
								addVertex(worldMeshes[meshX][meshY][? "wallMesh"], [x1, y1, zz - TileDim * 1.5], norm, [uvs[0], uvs[3]], c_white, 1);
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
					var entity = new Entity("Brick Wall")
						.addComponent("Physics")
						.addComponent("Impassable",   {bumping: true})
						.addComponent("Health",    {hp: 1})
						.addComponent("Position",  {x: x1, y: y1, z: 0})
						.addComponent("WorldTile", {gridX: x1/TileDim, gridY: y1/TileDim, isBlocking: true, worldMeshes: ["floor", "wall"]});

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
						.addComponent("SteppedOn")
						.addComponent("HurtSprite")
						.addComponent("HurtColor")
						.addComponent("WindShader")
						.addComponent("BillboardMesh")
						.addComponent("WorldTile", {gridX: x1/TileDim, gridY: y1/TileDim});

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
						.addComponent("HurtSprite", {sprite: sBBGrass_Tall_Stepped})
						.addComponent("HurtColor")
						.addComponent("WindShader")
						.addComponent("BillboardMesh")
						.addComponent("WorldTile", {gridX: x1/TileDim, gridY: y1/TileDim});

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
						.addComponent("WorldTile", {gridX: x1/TileDim, gridY: y1/TileDim, isBlocking: true, worldMeshes: ["canopy"]});

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
	
	var meshes = ["floor", "wall", "canopy"];	
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
				shader_set(shWind);
					vertex_submit(worldMeshes[i][j][? "canopyMesh"], pr_trianglelist, DefaultTexture);
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
	}
#endregion

#region Test Enemy
	var slimeX = 192;
	var slimeY = 448;
	var slimeZ =   0;

	var slime = new Entity("Slime")
		.addComponent("Physics",      {maxFlash:   24})
		.addComponent("Impassable",   {bumping: false})
		.addComponent("Health",       {hp: 15, maxHP: 15, deathTimer: 24})
		.addComponent("ShakeScreen",  {screenShake: 12, screenShakeIntensity: .1})
		.addComponent("Position",     {x: slimeX, y: slimeY, z: slimeZ})
		.addComponent("Transform",    {x: 16,  y: 16})
		.addComponent("Sprite",       {sprite: sSlime})
		.addComponent("HurtSubimage", {hurtTimer: 24, subimage: 1})
		.addComponent("HurtColor",    {hurtTimer: 24, baseColor: c_orange})
		.addComponent("DefaultShader")
		.addComponent("BillboardMesh", {baseColor: c_orange})
		
		.addComponent("MiniMapSprite")
		.addComponent("DeathParticle")
		.addComponent("DamageSound")
		.addComponent("DeathSound")

	var brain = instance_create_layer(slimeX, slimeY, "Instances", Brain, {parentEntity: slime});

	slime.fireEvent(EntityCreateEvent);
	entities[? slime.uuid] = slime;
	
	slimeX = 224;
	slimeY = 480;
	slimeZ =   0;

	slime = new Entity("Slime")
		.addComponent("Physics",      {maxFlash:   24})
		.addComponent("Impassable",   {bumping: false})
		.addComponent("Health",       {deathTimer: 24})
		.addComponent("ShakeScreen",  {screenShake: 12, screenShakeIntensity: .1})
		.addComponent("Position",     {x: slimeX, y: slimeY, z: slimeZ})
		.addComponent("Transform",    {x: 16,  y: 16})
		.addComponent("Sprite",       {sprite: sSlime})
		.addComponent("HurtSubimage", {hurtTimer: 24, subimage: 1})
		.addComponent("HurtColor",    {hurtTimer: 24})
		.addComponent("DefaultShader")
		.addComponent("BillboardMesh")
		
		.addComponent("MiniMapSprite")
		.addComponent("DeathParticle")
		.addComponent("DamageSound")
		.addComponent("DeathSound")

	brain = instance_create_layer(slimeX, slimeY, "Instances", Brain, {parentEntity: slime});

	slime.fireEvent(EntityCreateEvent);
	entities[? slime.uuid] = slime;
	
	slimeX = 192;
	slimeY = 480;
	slimeZ =   0;

	slime = new Entity("Slime")
		.addComponent("Physics",      {maxFlash:   24})
		.addComponent("Impassable",   {bumping: false})
		.addComponent("Health",       {deathTimer: 24})
		.addComponent("ShakeScreen",  {screenShake: 12, screenShakeIntensity: .1})
		.addComponent("Position",     {x: slimeX, y: slimeY, z: slimeZ})
		.addComponent("Transform",    {x: 16,  y: 16})
		.addComponent("Sprite",       {sprite: sSlime})
		.addComponent("HurtSubimage", {hurtTimer: 24, subimage: 1})
		.addComponent("HurtColor",    {hurtTimer: 24})
		.addComponent("DefaultShader")
		.addComponent("BillboardMesh")
		
		.addComponent("MiniMapSprite")
		.addComponent("DeathParticle")
		.addComponent("DamageSound")
		.addComponent("DeathSound")

	brain = instance_create_layer(slimeX, slimeY, "Instances", Brain, {parentEntity: slime});

	slime.fireEvent(EntityCreateEvent);
	entities[? slime.uuid] = slime;
#endregion

