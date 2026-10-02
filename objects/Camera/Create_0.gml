gpu_set_ztestenable(true); //We just have to set these so openGL knows we're using 3D rendering
gpu_set_zwriteenable(true);

hp    = 6;
maxHP = 6;

z             =  16;       //GM doesn't give objects a default z so we have to define it every time :(
lookDir       = 270;       //Since we're locked to a grid, lookDir is always going to be a multiple of 90					       
lookPit       =   0;       //We may want to script the player looking up or down, so we'll keep track of the pitch					       
lookDirOffset =   0;       //Offsets used for the lookState
lookPitOffset =   0;


xOffset       =   0;	   //Depending on which direction we're facing, we change our position relative to the tile
yOffset       =   0;	   //This is represented as an offset from 0 - tileDimension. Just to make things look consistent

xFromOffset   =   0;	   //These offsets change the position of the "eyes" of the player,
yFromOffset   =   0;	   //Used for head bobbing and stuff like that
zOffset       =   0;

xToOffset     =   0;	   //And these offsets are for nodding and shaking the head
yToOffset     =   0;
zToOffset     =   0;


moveSpeedFrames = 12;

animPos         =  0;
bumpAnim = animcurve_get_channel(acBump, 0);

xMoveTarget = x;           //When we're moving, xyMoveTarget keeps track of the grid position we're moving to
yMoveTarget = y;
xPrevious   = x;           //Last tile we steeped on
yPrevious   = y;
xMoveInc    = 0;           //How many pixels we move every frame of the moveState
yMoveInc    = 0;



//Here I'm using a pattern called a 'state machine'. You don't want to process every action every frame, for example;
//If you move your character to another square, you don't want to be able to turn mid-animation
//Similarly you wouldn't want to be reading movement inputs when you are in a menu

//So if our Camera is in the inputState, we should only be reading inputs.
//If we find that the player inputed a move command, we'll enter the moveState, where we
//will move the player every frame until they reach a target destination



//Here we define our states using the syntax variableName = function() {}
//This defines a function that can only be used by this object, so the Camera and Menu objects
//can have different inputState functions for example

waitState = function() {};

inputState = function() {
	//These are our deltas - eg if we press left or right our dDir will be + or - 90
	var dX   = 0, dY = 0;  
	var dDir = 0;	
	var gridX = floor(x / World.meshTileDim);
	var gridY = floor(y / World.meshTileDim);
	
	
	//Attack
	if(mouse_check_button(mb_left)) {
		var xx = 30 *  dcos(lookDir) + xOffset
		var yy = 30 * -dsin(lookDir) + yOffset
		var slash = instance_create_layer(x + xx, y + yy, "Instances", WeaponSlash);
		slash.z = z;
		
		//Check for collisions
		var entities = ds_map_keys_to_array(World.entities, []);
		for (var i = 0; i < array_length(entities); ++i) {
			var entityID = entities[i];
		    var entity   = World.entities[? entityID];
			
			var entityX  = entity.get("Position", "x");
			var entityY  = entity.get("Position", "y");
			
			if (entityX != x + 32 *  dcos(lookDir) || entityY!= y + 32 * -dsin(lookDir)) continue;
			
			var event = new Event("TakeDamage", {amount: roll("1d6")})
			event = entity.fireEvent(event);
		}
		
		for (var i = 0; i < instance_number(Enemy); ++i) {
		    var enemy = instance_find(Enemy, i);
			if(enemy.x == x + 32 *  dcos(lookDir) and enemy.y == y + 32 * -dsin(lookDir)) {
				enemy.takeDamage(1);
				break;
			}
		}
				
		xPrevious = x;
		yPrevious = y;
		xMoveTarget = x + 8 *  dcos(lookDir);
		yMoveTarget = y + 8 * -dsin(lookDir);
		
		state = bumpState;
		addTimesource("Attack", id, 24, attackFunc);
		return;
	}
	
	
	//Look around
	if(mouse_check_button_pressed(mb_right)) {
		state = lookState; //Set our state and reset our mouse position
		xOffset = 16;
		yOffset = 16;
		window_mouse_set(window_get_width()/2, window_get_height()/2);
		return; //Return causes the function we're in - inputState - to finish.
	}
	
	
	//Turn
	dDir = 90 * ( keyboard_check(ord("A")) - keyboard_check(ord("D")) );
	if(dDir != 0) {
		addTimesource("Turn", id, moveSpeedFrames, turnFunc);
		
		state = turnState;
		lookDirInc = dDir / moveSpeedFrames;
		targetLookDir = (lookDir + dDir + 360) mod 360;
		
		switch(targetLookDir) {
			//So this code will only execute if we're facing right
			case 0:
				targetxOffset =  0;
				targetyOffset = 16;
				break;
			//up
			case 90:
				targetxOffset = 16;
				targetyOffset = 32;
				break;
			//Left
			case 180:
				targetxOffset = 32;
				targetyOffset = 16;
				break;
			//Down
			case 270:
				targetxOffset = 16;
				targetyOffset =  0;
				break;
		}
		
		return;
	}	
	switch(lookDir) {
		case 0:
			xOffset =  0;
			yOffset = 16;
			break;
		case 90:
			xOffset = 16;
			yOffset = 30;
			break;
		case 180:
			xOffset = 30;
			yOffset = 16;
			break;
		case 270:
			xOffset = 16;
			yOffset =  0;
			break;
	}

		
	//Move forward and back
	dX = 32 *  dcos(lookDir) * ( keyboard_check(ord("W")) - keyboard_check(ord("S")) );
	dY = 32 * -dsin(lookDir) * ( keyboard_check(ord("W")) - keyboard_check(ord("S")) );
	if(dX != 0 || dY != 0) {
		var collis = tilemap_get_at_pixel(World.coll, x + dX, y + dY);
		if collis {
			xMoveTarget = x + dX;
			yMoveTarget = y + dY;		
			addTimesource("Bump", id, moveSpeedFrames, bumpFunc);
			addTimesource("BloodSplatter", id, moveSpeedFrames / 4, createBloodDecal);
			
			state = bumpState;
			return;
		};
		
		xMoveTarget = x + dX;
		yMoveTarget = y + dY;		
		addTimesource("Move", id, moveSpeedFrames, moveFunc);
		
		state = moveState;
		xMoveInc = dX / moveSpeedFrames;
		yMoveInc = dY / moveSpeedFrames;
		return;
	}	


	//Strafe
	dX = 32 *  dcos(lookDir + 90) * ( keyboard_check(ord("Q")) - keyboard_check(ord("E")) );
	dY = 32 * -dsin(lookDir + 90) * ( keyboard_check(ord("Q")) - keyboard_check(ord("E")) );
	if(dX != 0 || dY != 0) {	
		var collis = tilemap_get_at_pixel(World.coll, x + dX, y + dY);
		if collis {
			xMoveTarget = x + dX;
			yMoveTarget = y + dY;		
			addTimesource("Bump", id, moveSpeedFrames, bumpFunc);
			addTimesource("BloodSplatter", id, moveSpeedFrames / 4, createBloodDecal);
			
			state = bumpState;
			return;
		};
		
		xMoveTarget = x + dX;
		yMoveTarget = y + dY;
		addTimesource("Move", id, moveSpeedFrames, moveFunc);
		
		state = moveState;
		xMoveInc = dX / moveSpeedFrames;
		yMoveInc = dY / moveSpeedFrames;
		return;
	}

	
	zOffset     = lerp(zOffset, 0, .5);
	xFromOffset = lerp(xFromOffset, 0, .5);
	yFromOffset = lerp(yFromOffset, 0, .5);
}

lookState = function() {
	var mx = window_mouse_get_x(), my = window_mouse_get_y();
	var cx = window_get_width()/2, cy = window_get_height()/2;
	
	lookDirOffset -= ( mx - cx ) / 5;
	lookPitOffset += ( my - cy ) / 5;
	
	//-80 < lookPit + lookPitOffset < 80
	lookPitOffset = clamp(lookPitOffset, -80 - lookPit, 80 - lookPit);	
	
	window_mouse_set(cx, cy);
	
	if(mouse_check_button_pressed(mb_right)) {
		var compundDir = (lookDir + lookDirOffset + 360) mod 360;
		lookDir = round(compundDir / 90) * 90;
		lookDirOffset = compundDir - lookDir;
		
		state = inputState;
	}
}

moveState = function() {
	x += xMoveInc;
	y += yMoveInc;
	zOffset = lerp(zOffset, dsin(current_time / 3) * 3, .5);
	xFromOffset = lerp(xFromOffset, dsin(current_time / 5), .5);
	yFromOffset = lerp(yFromOffset, dsin(current_time / 5), .5);
}
moveFunc  = function() {
	x = xMoveTarget;
	y = yMoveTarget;
	xPrevious = x;
	yPrevious = y;
	state = inputState;
	
	var event = new Event("Step", {x: x, y: y, z: z - 16});
	event.fire();
}

bumpState = function() { 
	var delta = animcurve_channel_evaluate(bumpAnim, animPos / 12);
	x = lerp(xPrevious, xMoveTarget, delta);
	y = lerp(yPrevious, yMoveTarget, delta);
	
	animPos ++;
}
bumpFunc  = function() {
	x = xPrevious;
	y = yPrevious;	
	animPos = 0;
	state = inputState;
}

createBloodDecal = function() {
	hp = max(0, hp - 1);
	var spr = sBloodDecal;
	if (hp == 0) spr = sBloodDecal_Death;
	
	var dir = point_direction(xPrevious, yPrevious, xMoveTarget, yMoveTarget);
	
	var blood = instance_create_layer(xPrevious, yPrevious, "Instances", Decal);
	blood.sprite_index = spr;
	blood.lookDir = dir;
	blood.createMesh();
}

attackFunc = function() {
	x = xPrevious;
	y = yPrevious;
	animPos = 0;
	state = inputState;
}

turnState = function() {
	lookDir = (lookDir + lookDirInc + 360) mod 360;
	xOffset = lerp(xOffset, targetxOffset, .1);
	yOffset = lerp(yOffset, targetyOffset, .1);
}
turnFunc = function() {
	lookDir = targetLookDir;
	xOffset = targetxOffset;
	yOffset = targetyOffset;
	state = inputState;
}


//And we set our state equal to the function name without ()
state = inputState;

