function computeDjikstra() {
	var djikstra;
		var collisions = layer_tilemap_get_id("Collisions");
		var xx    = oPlayer.xTarget / 16, yy = oPlayer.yTarget / 16;
		var dist  = 1;
		var queue = [{xx: xx, yy: yy, d: 0}];
	
		djikstra = [[]];
		for (var i = 0; i < floor(room_width / 16); ++i) {
		    for (var j = 0; j < floor(room_height / 16); ++j) {
			    djikstra[i][j] = undefined;
			}
		}
		djikstra[xx][yy] = 0;
	
		while(array_length(queue) > 0) {
			xx = queue[0].xx;
			yy = queue[0].yy;
			dist = queue[0].d + 1;
		
			for (var i = 0; i < 3; ++i) {
			    for (var j = 0; j < 3; ++j) {
				
					if i == 1 and j == 1 continue;
				
					if !is_undefined(djikstra[xx + i - 1][yy + j - 1]) continue;
				
					var t = tilemap_get(collisions, xx + i - 1, yy + j - 1);
					if t continue;
				
					djikstra[xx + i - 1][yy + j - 1] = dist;
					array_push(queue, {xx: xx + i - 1, yy: yy + j - 1, d: dist})
				}
			}
		
			array_delete(queue, 0, 1);
		}
	return djikstra;
	}