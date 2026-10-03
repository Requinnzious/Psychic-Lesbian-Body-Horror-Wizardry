identityMatrix = matrix_build( 0,   0, 0, 0, 0,  0,  1,  1,  1);

entities    = ds_map_create();
createEvent = new Event("Create", {});
renderEvent = new Event("Render", {x: 0, y: 0, z: 0});

#region Store the tilemap
	tiles = [];
	var meta  = layer_tilemap_get_id("Meta");
	coll  = layer_tilemap_get_id("Collisions");
	for (var i = 0; i < room_width / 32; ++i) {
	    array_push(tiles, []);
		for (var j = 0; j < room_height / 32; ++j) {
			var tile   = tilemap_get_at_pixel(meta, i * 32, j * 32);
			var collis = tilemap_get_at_pixel(coll, i * 32, j * 32);
		    array_push(tiles[i], {tile: tile, collis: collis});
		}
	}
	cols = array_length(tiles);
	rows = array_length(tiles[0]);
#endregion

#region Construct the mesh of the level
	var uvs, nullUVs = sprite_get_uvs(sNull, 0);
	var floorNorm = [0,0,1];

	floorMesh   = vertex_create_buffer();
	wallMesh    = vertex_create_buffer();
	canopyMesh  = vertex_create_buffer();
	vertex_begin(floorMesh,  vFormat);
	vertex_begin(wallMesh,   vFormat);
	vertex_begin(canopyMesh, vFormat);

	for (var i = 0; i < cols; ++i) {
	    for (var j = 0; j < rows; ++j) {
		    var tile   = tiles[i][j].tile;
		    var collis = tiles[i][j].collis;
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
		
			//Make the floor tile
			var x1 = i * TileDim;
			var y1 = j * TileDim;
			var x2 = i * TileDim + TileDim;
			var y2 = j * TileDim + TileDim;
		
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
				addVertex(wallMesh, [x1, y1, zz - TileDim * 1.5], norm, [uvs[2], uvs[3]], c_white, 1);
			
				addVertex(wallMesh, [x2, y1, zz],               norm, [uvs[0], uvs[1]], c_white, 1);
				addVertex(wallMesh, [x1, y1, zz - TileDim * 1.5], norm, [uvs[2], uvs[3]], c_white, 1);
				addVertex(wallMesh, [x2, y1, zz - TileDim * 1.5], norm, [uvs[0], uvs[3]], c_white, 1);
			}
			if(sWall) {
				norm = [0, 1, 0];
				addVertex(wallMesh, [x1, y2, zz],               norm, [uvs[0], uvs[1]], c_white, 1);
				addVertex(wallMesh, [x2, y2, zz],               norm, [uvs[2], uvs[1]], c_white, 1);
				addVertex(wallMesh, [x2, y2, zz - TileDim * 1.5], norm, [uvs[2], uvs[3]], c_white, 1);
			
				addVertex(wallMesh, [x1, y2, zz],               norm, [uvs[0], uvs[1]], c_white, 1);
				addVertex(wallMesh, [x2, y2, zz - TileDim * 1.5], norm, [uvs[2], uvs[3]], c_white, 1);
				addVertex(wallMesh, [x1, y2, zz - TileDim * 1.5], norm, [uvs[0], uvs[3]], c_white, 1);
			}
			if(eWall) {
				norm = [1, 0, 0];
				addVertex(wallMesh, [x2, y2, zz],               norm, [uvs[0], uvs[1]], c_white, 1);
				addVertex(wallMesh, [x2, y1, zz],               norm, [uvs[2], uvs[1]], c_white, 1);
				addVertex(wallMesh, [x2, y1, zz - TileDim * 1.5], norm, [uvs[2], uvs[3]], c_white, 1);
			
				addVertex(wallMesh, [x2, y2, zz],               norm, [uvs[0], uvs[1]], c_white, 1);
				addVertex(wallMesh, [x2, y1, zz - TileDim * 1.5], norm, [uvs[2], uvs[3]], c_white, 1);
				addVertex(wallMesh, [x2, y2, zz - TileDim * 1.5], norm, [uvs[0], uvs[3]], c_white, 1);
			}
			if(wWall) {
				norm = [-1, 0, 0];
				addVertex(wallMesh, [x1, y1, zz],               norm, [uvs[0], uvs[1]], c_white, 1);
				addVertex(wallMesh, [x1, y2, zz],               norm, [uvs[2], uvs[1]], c_white, 1);
				addVertex(wallMesh, [x1, y2, zz - TileDim * 1.5], norm, [uvs[2], uvs[3]], c_white, 1);
			
				addVertex(wallMesh, [x1, y1, zz],               norm, [uvs[0], uvs[1]], c_white, 1);
				addVertex(wallMesh, [x1, y2, zz - TileDim * 1.5], norm, [uvs[2], uvs[3]], c_white, 1);
				addVertex(wallMesh, [x1, y1, zz - TileDim * 1.5], norm, [uvs[0], uvs[3]], c_white, 1);
			}
		
			var xAvg = (x1 + x2) / 2;
			var yAvg = (y1 + y2) / 2;
			
			//Mountains
			if tile == TileTypes.MOUNTAIN {
				uvs = sprite_get_uvs(sMountain, irandom(sprite_get_number(sMountain) - 1));
				var uAverage = (uvs[0] + uvs[2]) / 2;
				var vAverage = (uvs[1] + uvs[3]) / 2;
			
				addVertex(wallMesh, [xAvg, yAvg, 32], [  0,  .5, .5], [uAverage, vAverage], c_white, 1);
				addVertex(wallMesh, [x2,     y2,  0], [  0,  .5, .5], [uvs[2],     uvs[3]], c_white, 1);
				addVertex(wallMesh, [x1,     y2,  0], [  0,  .5, .5], [uvs[0],     uvs[3]], c_white, 1);
			
				addVertex(wallMesh, [xAvg, yAvg, 32], [-.5,   0, .5], [uAverage, vAverage], c_white, 1);
				addVertex(wallMesh, [x1,     y2,  0], [-.5,   0, .5], [uvs[2],     uvs[3]], c_white, 1);
				addVertex(wallMesh, [x1,     y1,  0], [-.5,   0, .5], [uvs[0],     uvs[3]], c_white, 1);
			
				addVertex(wallMesh, [xAvg, yAvg, 32], [  0, -.5, .5], [uAverage, vAverage], c_white, 1);
				addVertex(wallMesh, [x1,     y1,  0], [  0, -.5, .5], [uvs[2],     uvs[3]], c_white, 1);
				addVertex(wallMesh, [x2,     y1,  0], [  0, -.5, .5], [uvs[0],     uvs[3]], c_white, 1);
			
				addVertex(wallMesh, [xAvg, yAvg, 32], [ .5,   0, .5], [uAverage, vAverage], c_white, 1);
				addVertex(wallMesh, [x2,     y1,  0], [ .5,   0, .5], [uvs[2],     uvs[3]], c_white, 1);
				addVertex(wallMesh, [x2,     y2,  0], [ .5,   0, .5], [uvs[0],     uvs[3]], c_white, 1);
			}
		
			//Grass
			if tile == TileTypes.GRASS {
				var entity = new Entity();

				entity.addComponent("Physics");
				entity.addComponent("Health",    {hp: 1});
				entity.addComponent("Position",  {x: x1, y: y1, z: 0});
				entity.addComponent("Transform", {x: 16, y: 16});
				entity.addComponent("Sprite",    {randomSubimage: true});
				entity.addComponent("SteppedOn");
				entity.addComponent("HurtSprite");
				entity.addComponent("HurtColor");
				entity.addComponent("WindShader");
				entity.addComponent("BillboardMesh");

				entity.fireEvent(createEvent);

				entities[? entity.uuid] = entity;
			}		
			if tile == TileTypes.TALLGRASS {
				var entity = new Entity();
			
				entity.addComponent("Physics");
				entity.addComponent("Health",     {hp: 2});
				entity.addComponent("Position",   {x: x1, y: y1, z: 0});
				entity.addComponent("Transform",  {x: 16, y: 16});
				entity.addComponent("Sprite",     {sprite: sBBGrass_Tall, randomSubimage: true});
				entity.addComponent("SteppedOn",  {sprite: sBBGrass_Tall_Stepped});
				entity.addComponent("HurtSprite", {sprite: sBBGrass_Tall_Stepped});
				entity.addComponent("HurtColor");
				entity.addComponent("WindShader");
				entity.addComponent("BillboardMesh");

				entity.fireEvent(createEvent);
						
				entities[? entity.uuid] = entity;
			}		
			if tile == TileTypes.FAIRYCIRCLE {
				var shrooms = 8;
				var theta   = 0;
				for (var k = 0; k < shrooms; ++k) {
					var shroomX = x1 + 16 + lengthdir_x(32, theta) + random_range(-2, 2);
					var shroomY = y1 + 16 + lengthdir_y(32, theta) + random_range(-2, 2);
				
					var entity = new Entity();
					entity.addComponent("Position",  {x: shroomX, y: shroomY, z: 0});
					entity.addComponent("Sprite",    {sprite: sBBShroom, randomSubimage: true});
					entity.addComponent("WindShader");
					entity.addComponent("BillboardMesh");

					entity.fireEvent(createEvent);
				
					entities[? entity.uuid] = entity;
				
					theta += 360/shrooms;
				}
			}		

			//Trees
			if tile == TileTypes.TREE {
				var entity = new Entity();
				entity.addComponent("Physics");
				entity.addComponent("Position",  {x: xAvg + random_range(-2, 2), y: yAvg + random_range(-2, 2), z: 0});
				entity.addComponent("Sprite",    {sprite: sTreeTexture});
				entity.addComponent("WindShader");
				entity.addComponent("BillboardMesh");

				entity.fireEvent(createEvent);

				entities[? entity.uuid] = entity;

				#region Foliage
					//Make small canopy
					uvs    = sprite_get_uvs(sCanopyTexture, irandom(sprite_get_number(sCanopyTexture) - 1));
					var width  = random_range(-16, 16) + sprite_get_width(sCanopyTexture);
					var height = random_range(-16, 16) + sprite_get_height(sCanopyTexture);
			
					x1 = xAvg - width  / 2;
					x2 = xAvg + width  / 2;
					y1 = yAvg - height / 2;
					y2 = yAvg + height / 2;
			
					var z1 = random_range(48, 64);
					var z2 = random_range(48, 64);
			
					addVertex(canopyMesh, [x1, y1, z1], [0, 0, -1], [uvs[0], uvs[1]], c_white, 1);
					addVertex(canopyMesh, [x2, y1, z1], [0, 0, -1], [uvs[2], uvs[1]], c_white, 1);
					addVertex(canopyMesh, [x2, y2, z2], [0, 0, -1], [uvs[2], uvs[3]], c_white, 1);
					addVertex(canopyMesh, [x1, y1, z1], [0, 0, -1], [uvs[0], uvs[1]], c_white, 1);
					addVertex(canopyMesh, [x2, y2, z2], [0, 0, -1], [uvs[2], uvs[3]], c_white, 1);
					addVertex(canopyMesh, [x1, y2, z2], [0, 0, -1], [uvs[0], uvs[3]], c_white, 1);
			
			
					//Make large canopy
					uvs = sprite_get_uvs(sCanopyTexture_1, irandom(sprite_get_number(sCanopyTexture_1)- 1));
					width  = random_range(-16, 16) + sprite_get_width(sCanopyTexture_1);
					height = random_range(-16, 16) + sprite_get_height(sCanopyTexture_1);
			
					x1 = xAvg - width  / 2;
					x2 = xAvg + width  / 2;
					y1 = yAvg - height / 2;
					y2 = yAvg + height / 2;
			
					z1 = random_range(80, 96);
					z2 = random_range(80, 96);
			
					addVertex(canopyMesh, [x1, y1, z1], [0, 0, -1], [uvs[0], uvs[1]], c_white, 1);
					addVertex(canopyMesh, [x2, y1, z1], [0, 0, -1], [uvs[2], uvs[1]], c_white, 1);
					addVertex(canopyMesh, [x2, y2, z2], [0, 0, -1], [uvs[2], uvs[3]], c_white, 1);
			
					addVertex(canopyMesh, [x1, y1, z1], [0, 0, -1], [uvs[0], uvs[1]], c_white, 1);
					addVertex(canopyMesh, [x2, y2, z2], [0, 0, -1], [uvs[2], uvs[3]], c_white, 1);
					addVertex(canopyMesh, [x1, y2, z2], [0, 0, -1], [uvs[0], uvs[3]], c_white, 1);
			
			
					//South wall
					addVertex(canopyMesh, [x1, y2, z1 + height], [0, 1, 0], [uvs[0], uvs[1]], c_white, 1);
					addVertex(canopyMesh, [x2, y2, z1 + height], [0, 1, 0], [uvs[2], uvs[1]], c_white, 1);
					addVertex(canopyMesh, [x2, y2,          z2], [0, 1, 0], [uvs[2], uvs[3]], c_white, 1);
					addVertex(canopyMesh, [x1, y2, z1 + height], [0, 1, 0], [uvs[0], uvs[1]], c_white, 1);
					addVertex(canopyMesh, [x2, y2,          z2], [0, 1, 0], [uvs[2], uvs[3]], c_white, 1);
					addVertex(canopyMesh, [x1, y2,          z2], [0, 1, 0], [uvs[0], uvs[3]], c_white, 1);
					if random(1) < .15 {
						var foliageUVs = sprite_get_uvs(sFoliage, irandom(sprite_get_number(sFoliage) - 1));
						var fx1 = x1  + irandom(width - sprite_get_width(sFoliage));
						var fx2 = fx1 + sprite_get_width(sFoliage);
						var foliageHeight = sprite_get_height(sFoliage)
				
						addVertex(canopyMesh, [fx1, y2, z1],                 [0, 1, 0], [foliageUVs[0], foliageUVs[1]], c_white, 1);
						addVertex(canopyMesh, [fx2, y2, z1],                 [0, 1, 0], [foliageUVs[2], foliageUVs[1]], c_white, 1);
						addVertex(canopyMesh, [fx2, y2, z1 - foliageHeight], [0, 1, 0], [foliageUVs[2], foliageUVs[3]], c_white, 1);
						addVertex(canopyMesh, [fx1, y2, z1],                 [0, 1, 0], [foliageUVs[0], foliageUVs[1]], c_white, 1);
						addVertex(canopyMesh, [fx2, y2, z1 - foliageHeight], [0, 1, 0], [foliageUVs[2], foliageUVs[3]], c_white, 1);
						addVertex(canopyMesh, [fx1, y2, z1 - foliageHeight], [0, 1, 0], [foliageUVs[0], foliageUVs[3]], c_white, 1);
					}
			
					//North wall
					addVertex(canopyMesh, [x2, y1, z1 + height], [0,-1, 0], [uvs[0], uvs[1]], c_white, 1);
					addVertex(canopyMesh, [x1, y1, z1 + height], [0,-1, 0], [uvs[2], uvs[1]], c_white, 1);
					addVertex(canopyMesh, [x1, y1,          z2], [0,-1, 0], [uvs[2], uvs[3]], c_white, 1);
					addVertex(canopyMesh, [x2, y1, z1 + height], [0,-1, 0], [uvs[0], uvs[1]], c_white, 1);
					addVertex(canopyMesh, [x1, y1,          z2], [0,-1, 0], [uvs[2], uvs[3]], c_white, 1);
					addVertex(canopyMesh, [x2, y1,          z2], [0,-1, 0], [uvs[0], uvs[3]], c_white, 1);
					if random(1) < .15 {
						var foliageUVs = sprite_get_uvs(sFoliage, irandom(sprite_get_number(sFoliage) - 1));
						var fx1 = x2  - irandom(width - sprite_get_width(sFoliage));
						var fx2 = fx1 - sprite_get_width(sFoliage);
						var foliageHeight = sprite_get_height(sFoliage)
				
						addVertex(canopyMesh, [fx2, y1, z1],                 [0, -1, 0], [foliageUVs[0], foliageUVs[1]], c_white, 1);
						addVertex(canopyMesh, [fx1, y1, z1],                 [0, -1, 0], [foliageUVs[2], foliageUVs[1]], c_white, 1);
						addVertex(canopyMesh, [fx1, y1, z1 - foliageHeight], [0, -1, 0], [foliageUVs[2], foliageUVs[3]], c_white, 1);
						addVertex(canopyMesh, [fx2, y1, z1],                 [0, -1, 0], [foliageUVs[0], foliageUVs[1]], c_white, 1);
						addVertex(canopyMesh, [fx1, y1, z1 - foliageHeight], [0, -1, 0], [foliageUVs[2], foliageUVs[3]], c_white, 1);
						addVertex(canopyMesh, [fx2, y1, z1 - foliageHeight], [0, -1, 0], [foliageUVs[0], foliageUVs[3]], c_white, 1);
					}
			
					//East wall
					addVertex(canopyMesh, [x2, y2, z1 + height], [1, 0, 0], [uvs[0], uvs[1]], c_white, 1);
					addVertex(canopyMesh, [x2, y1, z1 + height], [1, 0, 0], [uvs[2], uvs[1]], c_white, 1);
					addVertex(canopyMesh, [x2, y1,          z2], [1, 0, 0], [uvs[2], uvs[3]], c_white, 1);
					addVertex(canopyMesh, [x2, y2, z1 + height], [1, 0, 0], [uvs[0], uvs[1]], c_white, 1);
					addVertex(canopyMesh, [x2, y1,          z2], [1, 0, 0], [uvs[2], uvs[3]], c_white, 1);
					addVertex(canopyMesh, [x2, y2,          z2], [1, 0, 0], [uvs[0], uvs[3]], c_white, 1);
					if random(1) < .15 {
						var foliageUVs = sprite_get_uvs(sFoliage, irandom(sprite_get_number(sFoliage) - 1));
						var fy1 = y2  - irandom(width - sprite_get_width(sFoliage));
						var fy2 = fy1 - sprite_get_width(sFoliage);
						var foliageHeight = sprite_get_height(sFoliage)
				
						addVertex(canopyMesh, [x2, fy2, z1],                 [-1, 0, 0], [foliageUVs[0], foliageUVs[1]], c_white, 1);
						addVertex(canopyMesh, [x2, fy1, z1],                 [-1, 0, 0], [foliageUVs[2], foliageUVs[1]], c_white, 1);
						addVertex(canopyMesh, [x2, fy1, z1 - foliageHeight], [-1, 0, 0], [foliageUVs[2], foliageUVs[3]], c_white, 1);
						addVertex(canopyMesh, [x2, fy2, z1],                 [-1, 0, 0], [foliageUVs[0], foliageUVs[1]], c_white, 1);
						addVertex(canopyMesh, [x2, fy1, z1 - foliageHeight], [-1, 0, 0], [foliageUVs[2], foliageUVs[3]], c_white, 1);
						addVertex(canopyMesh, [x2, fy2, z1 - foliageHeight], [-1, 0, 0], [foliageUVs[0], foliageUVs[3]], c_white, 1);
					}
			
					//west wall
					addVertex(canopyMesh, [x1, y1, z1 + height], [-1, 0, 0], [uvs[0], uvs[1]], c_white, 1);
					addVertex(canopyMesh, [x1, y2, z1 + height], [-1, 0, 0], [uvs[2], uvs[1]], c_white, 1);
					addVertex(canopyMesh, [x1, y2,          z2], [-1, 0, 0], [uvs[2], uvs[3]], c_white, 1);
					addVertex(canopyMesh, [x1, y1, z1 + height], [-1, 0, 0], [uvs[0], uvs[1]], c_white, 1);
					addVertex(canopyMesh, [x1, y2,          z2], [-1, 0, 0], [uvs[2], uvs[3]], c_white, 1);
					addVertex(canopyMesh, [x1, y1,          z2], [-1, 0, 0], [uvs[0], uvs[3]], c_white, 1);
					if random(1) < .15 {
						var foliageUVs = sprite_get_uvs(sFoliage, irandom(sprite_get_number(sFoliage) - 1));
						var fy1 = y1  + irandom(width - sprite_get_width(sFoliage));
						var fy2 = fy1 + sprite_get_width(sFoliage);
						var foliageHeight = sprite_get_height(sFoliage)
				
						addVertex(canopyMesh, [x1, fy1, z1],                 [-1, 0, 0], [foliageUVs[0], foliageUVs[1]], c_white, 1);
						addVertex(canopyMesh, [x1, fy2, z1],                 [-1, 0, 0], [foliageUVs[2], foliageUVs[1]], c_white, 1);
						addVertex(canopyMesh, [x1, fy2, z1 - foliageHeight], [-1, 0, 0], [foliageUVs[2], foliageUVs[3]], c_white, 1);
						addVertex(canopyMesh, [x1, fy1, z1],                 [-1, 0, 0], [foliageUVs[0], foliageUVs[1]], c_white, 1);
						addVertex(canopyMesh, [x1, fy2, z1 - foliageHeight], [-1, 0, 0], [foliageUVs[2], foliageUVs[3]], c_white, 1);
						addVertex(canopyMesh, [x1, fy1, z1 - foliageHeight], [-1, 0, 0], [foliageUVs[0], foliageUVs[3]], c_white, 1);
					}
				#endregion
			}
		}
	}

	vertex_end(floorMesh);
	vertex_end(wallMesh);
	vertex_end(canopyMesh);
#endregion

#region World Methods
	render = function() {
		var tex = sprite_get_texture(sPathTexture, 0);
		matrix_set(matrix_world, identityMatrix);
			vertex_submit(floorMesh, pr_trianglelist, tex);
			vertex_submit(wallMesh, pr_trianglelist,  tex);

		shader_set(shWind);
			vertex_submit(canopyMesh, pr_trianglelist,  tex);
		shader_reset();

		shader_set(shDefault);
			with Decal       vertex_submit(mesh, pr_trianglelist, tex);
			with WeaponSlash render();
		shader_reset();

		matrix_set(matrix_world, identityMatrix);
			with Mountain    render();

		renderEvent.fire();
	}
#endregion

#region Test Enemy
	var entity = new Entity();
	entity.addComponent("Physics",      {maxFlash:   24});
	entity.addComponent("Health",       {deathTimer: 24});
	entity.addComponent("ShakeScreen",  {screenShake: 12, screenShakeIntensity: .1});
	entity.addComponent("Position",     {x: 192, y: 448, z: 0});
	entity.addComponent("Transform",    {x: 16,  y: 16});
	entity.addComponent("Sprite",       {sprite: sSlime});
	entity.addComponent("HurtSubimage", {hurtTimer: 24, subimage: 1});
	entity.addComponent("HurtColor",    {hurtTimer: 24});
	entity.addComponent("DefaultShader");
	entity.addComponent("DebugDjikstra");
	entity.addComponent("BillboardMesh");

	entity.fireEvent(createEvent);
	entities[? entity.uuid] = entity;
#endregion


createEvent.fire();