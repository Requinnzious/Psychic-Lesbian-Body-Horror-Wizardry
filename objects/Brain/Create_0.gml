hopAnimation = animcurve_get_channel(acHop, 0);

subscriptions = [];

z             =  0;

xPrevious     =  x;
yPrevious     =  y;
zPrevious     =  z;

xTarget       =  x;
yTarget       =  y;
zTarget       =  z;

xMoveInc      =  0;
yMoveInc      =  0;
zMoveInc      =  0;

animPos       =  1;

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
			
			z  = 6 * animcurve_channel_evaluate(hopAnimation, animPos / Camera.moveSpeedFrames);
			
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
			var djikstraWidth  = array_length(Camera.djikstra);
			var djikstraHeight = array_length(Camera.djikstra[0]);
			var cellCosts      = [];
			
			var xx   = floor(x / TileDim);
			var yy   = floor(y / TileDim);
			var dist = Camera.djikstra[xx][yy];
			
			
			//Get the weight of nearby cells
			for (var i = 0; i < 3; ++i) {
			    for (var j = 0; j < 3; ++j) {
					if abs(i - 1) == abs(j - 1) and i - 1 != 0 continue;
					
				    var indX = xx + i - 1;
				    var indY = yy + j - 1;
					
					var weight = Camera.djikstra[indX][indY] ?? 42069;
					array_push(cellCosts, {weight: weight, x: indX, y: indY})
				}
			}
			
			//Sort by distance
			array_sort(cellCosts, function(current, next) {return current.weight - next.weight});
			
			//Check for entity collisions
			for (var i = 0; i < array_length(cellCosts); ++i) {
			    if ds_map_exists(_event.params.positions, $"X:{cellCosts[i].x * TileDim},Y:{cellCosts[i].y * TileDim},Z:{z}")
					|| cellCosts[i].weight == 0 {
					array_delete(cellCosts, i, 1);
					i--;
				}
			}
			
			//Filter out all distant tiles
			for (var i = 0; i < array_length(cellCosts); ++i) {
			    if cellCosts[i].weight == cellCosts[0].weight continue;
				array_delete(cellCosts, i, array_length(cellCosts) - i)
			}
			
			
			//Enter movement state
			var targetCell = cellCosts[irandom(array_length(cellCosts) - 1)];
			xTarget = targetCell.x * TileDim;
			yTarget = targetCell.y * TileDim;
			
			xMoveInc = (xTarget - x) / Camera.moveSpeedFrames;
			yMoveInc = (yTarget - y) / Camera.moveSpeedFrames;
			
			stateMachine.change("move");
			addTimesource($"{parentEntity.uuid}Movement", id, Camera.moveSpeedFrames, moveFunc);
			
			
			//Add our position to the positions list
			_event.params.positions[? $"X:{xTarget},Y:{yTarget},Z:{z}"] = "Slime";
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
	
	xPrevious = x;
	yPrevious = y;
	
	stateMachine.change("idle");
}


listen("Brain_Move");