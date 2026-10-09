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
			if parentEntity.get("Health", "hp") == 0 {
				mp_grid_add_cell(World.aStar, x/TileDim, y/TileDim);
				movePoints = 0;
				break;
			}
			
			
			mp_grid_clear_cell(World.aStar, x/TileDim, y/TileDim);
			
			if !mp_grid_path(World.aStar, World.path, x + 16, y + 16, _event.params.x + 16, _event.params.y + 16, false) break;
			
			var len         = path_get_length(World.path);
			var targetCellX = floor(path_get_x(World.path, TileDim/len) / TileDim) * TileDim;
			var targetCellY = floor(path_get_y(World.path, TileDim/len) / TileDim) * TileDim;
			
			//If we're not moving, we don't want to enter the move state
			if targetCellX == _event.params.x and targetCellY == _event.params.y {
				mp_grid_add_cell(World.aStar, x/TileDim, y/TileDim);
				break;
			}
			
			xTarget = targetCellX;
			yTarget = targetCellY;
			zTarget = z;
			
			mp_grid_add_cell(World.aStar, xTarget/TileDim, yTarget/TileDim);
			
			xMoveInc = (xTarget - x) / MoveFrames;
			yMoveInc = (yTarget - y) / MoveFrames;
			
			stateMachine.change("move");
			movePoints -= 100;
			var ts = time_source_create(time_source_game, MoveFrames, time_source_units_frames, moveFunc);
			time_source_start(ts);
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