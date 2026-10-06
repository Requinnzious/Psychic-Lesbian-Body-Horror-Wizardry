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

stateMachine = new SnowState("idle")
	.add("idle", {
		enter: function()  {show_debug_message("Hi!")},
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
			
			
			//Sort by distance
			array_sort(cellCosts, function(current, next) {return current.weight - next.weight});
				
			
			//Don't move into the player
			if cellCosts[0].x * TileDim == _event.params.x and cellCosts[0].y * TileDim == _event.params.y array_delete(cellCosts, 0, 1);
			
			
			//Filter out all distant tiles
			for (var i = 0; i < array_length(cellCosts); ++i) {
			    if cellCosts[i].weight <= dist continue;
				array_delete(cellCosts, i, array_length(cellCosts) - i)
			}

			
			//If we can't move, we don't
			if array_length(cellCosts) == 0 break;
			
			
			//Enter movement state
			var targetCell = cellCosts[irandom(array_length(cellCosts) - 1)];
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
	
	stateMachine.change("idle");
}


listen("Brain_Move");