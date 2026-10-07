hopAnimation = animcurve_get_channel(acHop, 0);

subscriptions = [];

z             =   0;
movePoints    = 100;

xPrevious     =   x;
yPrevious     =   y;
zPrevious     =   z;

xTarget       =   x;
yTarget       =   y;
zTarget       =   z;

xMoveInc      =   0;
yMoveInc      =   0;
zMoveInc      =   0;

animPos       =   1;

stateMachine = new SnowState("wait")
	.add("wait", {
		enter: function()  {},
		update: function() {}
	})
	.add("step", {
		enter: function()  {},
		update: function() {}
	})
	.add("move", {
		enter: function() {
		},
		update: function() {
			animPos++;
			
			x += xMoveInc;
			y += yMoveInc;
			
			z  = 6 * animcurve_channel_evaluate(hopAnimation, animPos / MoveFrames);
			
			var event = new Event("Place", {x: x, y: y, z: z});
			event = parentEntity.fireEvent(event);
			delete event;
		},
		leave: function() {
			animPos = 0;
			
			z = 0;
			
			var event = new Event("Place", {x: x, y: y, z: z});
			event = parentEntity.fireEvent(event);
			delete event;
		}
	})

update = function() {
	stateMachine.update();
}	
	
listen = function(eventName) {
	subscribe(eventName, self);
	array_push(subscriptions, eventName);
}
mute = function(eventName) {
	unsubscribe(eventName, self);
}

fireEvent = function(_event) {
	switch _event.type {
		case "Brain_Move":
			//if we're dead we probably shouldn't move :>
			if parentEntity.get("Health", "hp") == 0 break;
		
			var djikstraWidth  = array_length(Camera.djikstra);
			var djikstraHeight = array_length(Camera.djikstra[0]);
			var cellCosts      = [];
			
			var xx   = floor(x / TileDim);
			var yy   = floor(y / TileDim);
			var dist = Camera.djikstra[xx][yy];
			//Camera.djikstra[xx - 1][yy + 1] = ( (Camera.djikstra[xx - 1][yy + 1]) ?? 42069 ) + 1;
			//Camera.djikstra[xx + 1][yy - 1] = ( (Camera.djikstra[xx + 1][yy - 1]) ?? 42069 ) + 1;
			//Camera.djikstra[xx + 1][yy + 1] = ( (Camera.djikstra[xx + 1][yy + 1]) ?? 42069 ) + 1;
			//Camera.djikstra[xx - 1][yy - 1] = ( (Camera.djikstra[xx - 1][yy - 1]) ?? 42069 ) + 1;
			
			//Get the weight of nearby cells
			for (var i = 0; i < 3; ++i) {
			    for (var j = 0; j < 3; ++j) {
					if abs(i - 1) == abs(j - 1) continue; // and i - 1 != 0
					
				    var indX = xx + i - 1;
				    var indY = yy + j - 1;
					
					var weight = Camera.djikstra[indX][indY] ?? 42069;
					array_push(cellCosts, {weight: weight, x: indX, y: indY})
				}
			}
			
			
			//Check for entity collisions
			with Brain {
				for (var i = 0; i < array_length(cellCosts); ++i) {				
					var _delete = false;
					if xTarget == cellCosts[i].x * TileDim and yTarget == cellCosts[i].y * TileDim {
						_delete = true;
					}
				    if _delete	{
						array_delete(cellCosts, i, 1);
						i--;
					}
				}
			}
			#region Manually Check Impassable Entities (?)
				var entities = ds_map_keys_to_array(World.entities, []);
				for (var i = 0; i < array_length(entities); ++i) {
					var entityID = entities[i];
				    var entity   = World.entities[? entityID];
				
					if !entity.has("ImpassableComponent") continue;
				
					var entityX  = entity.get("Position", "x");
					var entityY  = entity.get("Position", "y");
				
					for (var j = 0; j < array_length(cellCosts); ++j) {				
						var _delete = false;
						if (entityX == cellCosts[j].x * TileDim && entityY == cellCosts[j].y * TileDim) {
							if !entity.get("Impassable", "bumping") bump = false;
							_delete = true;
							
							//YOOOOOO!!!!!!
							if entity.entityName == PlayerName _delete = false;
							Camera.djikstra[cellCosts[j].x + 1][cellCosts[j].y + 0] = max(1, ( (Camera.djikstra[cellCosts[j].x + 1][cellCosts[j].y + 0]) ?? 42069 ) - 1);
							Camera.djikstra[cellCosts[j].x - 1][cellCosts[j].y - 0] = max(1, ( (Camera.djikstra[cellCosts[j].x - 1][cellCosts[j].y - 0]) ?? 42069 ) - 1);
							Camera.djikstra[cellCosts[j].x + 0][cellCosts[j].y + 1] = max(1, ( (Camera.djikstra[cellCosts[j].x + 0][cellCosts[j].y + 1]) ?? 42069 ) - 1);
							Camera.djikstra[cellCosts[j].x - 0][cellCosts[j].y - 1] = max(1, ( (Camera.djikstra[cellCosts[j].x - 0][cellCosts[j].y - 1]) ?? 42069 ) - 1);
							Camera.djikstra[cellCosts[j].x + 1][cellCosts[j].y + 1] = max(1, ( (Camera.djikstra[cellCosts[j].x + 1][cellCosts[j].y + 1]) ?? 42069 ) - 1);
							Camera.djikstra[cellCosts[j].x - 1][cellCosts[j].y - 1] = max(1, ( (Camera.djikstra[cellCosts[j].x - 1][cellCosts[j].y - 1]) ?? 42069 ) - 1);
							Camera.djikstra[cellCosts[j].x + 1][cellCosts[j].y - 1] = max(1, ( (Camera.djikstra[cellCosts[j].x + 1][cellCosts[j].y - 1]) ?? 42069 ) - 1);
							Camera.djikstra[cellCosts[j].x - 1][cellCosts[j].y + 1] = max(1, ( (Camera.djikstra[cellCosts[j].x - 1][cellCosts[j].y + 1]) ?? 42069 ) - 1);
						}
					    if _delete	{
							array_delete(cellCosts, j, 1);
							j--;
						}
					}
				}
			#endregion
			
			
			//Sort by distance
			array_sort(cellCosts, function(current, next) {return current.weight - next.weight});
				
			
			//Don't move into the player
			if cellCosts[0].x * TileDim == _event.params.x and cellCosts[0].y * TileDim == _event.params.y break;//array_delete(cellCosts, 0, 1);
			
			
			var targetCell = cellCosts[irandom(array_length(cellCosts) - 1)];
			
			//Filter out all distant tiles
			for (var i = 0; i < array_length(cellCosts); ++i) {
			    if cellCosts[i].weight <= dist continue;
				if array_length(cellCosts) == 1 targetCell = cellCosts[0];
				array_delete(cellCosts, i, array_length(cellCosts) - i)
			}

			
			//If we can't move, we don't
			if array_length(cellCosts) > 0 targetCell = cellCosts[irandom(array_length(cellCosts) - 1)];
			
			
			//Enter movement state
			var targetCellX = targetCell.x * TileDim
			var targetCellY = targetCell.y * TileDim
			
			//If we're not moving, we don't want to enter the move state
			if targetCellX == x and targetCellY == y break;
			
			xTarget = targetCellX;
			yTarget = targetCellY;
			zTarget = z;
			
			xMoveInc = (xTarget - x) / MoveFrames;
			yMoveInc = (yTarget - y) / MoveFrames;
			
			stateMachine.change("move");
			addTimesource($"{parentEntity.uuid}Movement", id, MoveFrames, moveFunc);
			break;
	}
	return _event;
}

destroy = function() {
	for (var i = 0; i < array_length(self.subscriptions); ++i) {
	    mute(self.subscriptions[i]);
	}
	instance_destroy();
}

moveFunc  = function() {
	x = xTarget;
	y = yTarget;
	z = zTarget;
	
	xPrevious = x;
	yPrevious = y;
	zPrevious = z;
	
	stateMachine.change("wait");
}


listen("Brain_Move");