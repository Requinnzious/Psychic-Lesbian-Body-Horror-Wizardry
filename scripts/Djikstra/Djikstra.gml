enum DjikstraMode {
	UDLR,
	DIAG
}

function computeDjikstra(targetX, targetY, tileDim = 32, mode = DjikstraMode.UDLR) {
	var djikstra;
		var collisions = layer_tilemap_get_id("Collisions");
		var xx    = round(targetX / tileDim), yy = round(targetY / tileDim);
		
		var dist  = 1;
		var queue = [{xx: xx, yy: yy, d: 0}];
	
		djikstra = [[]];
		for (var i = 0; i < floor(room_width / tileDim); ++i) {
		    for (var j = 0; j < floor(room_height / tileDim); ++j) {
			    djikstra[i][j] = undefined;
			}
		}
		
		if xx < 0 or xx >= array_length(djikstra)    or 
		   yy < 0 or yy >= array_length(djikstra[0]) return self.djikstra;
		djikstra[xx][yy] = 0;
	
		while(array_length(queue) > 0) {
			xx = queue[0].xx;
			yy = queue[0].yy;
			dist = queue[0].d + 1;
		
			for (var i = 0; i < 3; ++i) {
			    for (var j = 0; j < 3; ++j) {
				
					switch(mode) {
						case DjikstraMode.DIAG:
							if i == 1 and j == 1 continue;
							break;
						case DjikstraMode.UDLR:
							if (abs(i - 1) == abs(j - 1)) continue;
							break;
					}
				
					if xx + i - 1 < 0 or xx + i - 1 >= array_length(djikstra)    or 
					   yy + j - 1 < 0 or yy + j - 1 >= array_length(djikstra[0]) continue; 
				
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