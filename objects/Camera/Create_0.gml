gpu_set_ztestenable(true); //We just have to set these so openGL knows we're using 3D rendering
gpu_set_zwriteenable(true);
application_surface_draw_enable(false);

screenSurf = surface_create(surface_get_width(application_surface), surface_get_height(application_surface));
surface1   = surface_create(surface_get_width(application_surface), surface_get_height(application_surface));
surface2   = surface_create(surface_get_width(application_surface), surface_get_height(application_surface));
surface3   = surface_create(surface_get_width(application_surface), surface_get_height(application_surface));

/// Shader parameters
// CRT emulation
crtDistortion   =    0; // screen distortion intensity
crtReflection   =    0; // border reflection intensity
crtShadowmask   =    0; // shadow mask intensity
crtScanline     =  .18; // scanline intensity
crtBleed        =    0; // bleed intensity
crtBleedSize    =   64; // bleed size
crtTint         =  .15; // dynamic colour tint intensity
crtVignette     =   .1; // vignette intensity
crtFilmgrain    =   .1; // film grain intensity
crtBrightness   =    0; // brightness boost/adjustment
crtContrast     =   .5; // contrast adjustment

// Specular light
// specular light colour
crtSpecularR    =   .9;
crtSpecularG    =  .75;
crtSpecularB    =  1.0;

// crtSpecularCol = c_white;
crtSpecularAmp  =  .03; // specular light amplitude/alpha
crtSpecularOffX =    0; // specular light offset x
crtSpecularOffY =  .25; // specular light offset y

// Final postprocessing FX
crtGlowFactor   =    0; // factor/multiplier of glow (hard-capped at certain amount)
crtGlowTint     = 0.75; // colour tint amount of blur (like chromatic aberration)
crtBlurSize     =    8; // half size of blur
crtBlurZoom     =  0.3; // zoom amount of blur

#region GUI
	CRTDebugUI = false;
	/// Window settings
	winWid = 1280;
	winHei =  720;
	winTargetW = 800;
	winTargetH = 600;

	/// Init the UI
	iui_init();
	UIScale = 1.0;
	UIMsg = "";
	UIMsgCtr = 0;

	/// State of the demo
	enum eDEMO_STATE {
		DEFAULT,
		CUSTOM
	}
	demoState = eDEMO_STATE.DEFAULT;
	demoBGList = iui_pack(-1, bgTest1, bgTest2, bgTest3, bgTest4, bgTest5, bgTest6);
	demoBGCurrent = -1;
	demoBGIdx = 0;

	demoCustomBGDir = "";
	demoCustomBG = -1;
#endregion

djikstra = computeDjikstra(x, y);


hp    = 6;
maxHP = 6;

z                    =  16;       //GM doesn't give objects a default z so we have to define it every time :(
lookDir              = 270;       //Since we're locked to a grid, lookDir is always going to be a multiple of 90					       
lookPit              =   0;       //We may want to script the player looking up or down, so we'll keep track of the pitch					       
lookDirOffset        =   0;       //Offsets used for the lookState
lookPitOffset        =   0;

screenShake          =   0;
screenShakeIntensity =   0;

xOffset              =   0;	   //Depending on which direction we're facing, we change our position relative to the tile
yOffset              =   0;	   //This is represented as an offset from 0 - tileDimension. Just to make things look consistent

xFromOffset          =   0;	   //These offsets change the position of the "eyes" of the player,
yFromOffset          =   0;	   //Used for head bobbing and stuff like that
zFromOffset          =   0;

xToOffset            =   0;	   //And these offsets are for nodding and shaking the head
yToOffset            =   0;
zToOffset            =   0;


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

endPlayerTurn = function(xx, yy, zz) {
	djikstra = computeDjikstra(xx, yy);
	
	var playerTurnEvent = new Event("PlayerTurn", { x: xx, y: yy, z: zz });
	playerTurnEvent = playerTurnEvent.fire();
	
	delete playerTurnEvent;
}

stateMachine = new SnowState("step", false)
	.add("idle", {
		enter: function() {},
		update: function() {}
	})

	.add("step", {
		enter: function() {
			stateMachine.change("input")
		},
		update: function() { stateMachine.change("input") }
	})

	.add("input", {
		enter: function() {},
		update: function() {
			//These are our deltas - eg if we press left or right our dDir will be + or - 90
			var dX   = 0, dY = 0;  
			var dDir = 0;	
			var gridX = floor(x / TileDim);
			var gridY = floor(y / TileDim);	
	
			//Attack
			if(GetAttackHeld()) {
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

				xPrevious = x;
				yPrevious = y;
				xMoveTarget = x + 8 *  dcos(lookDir);
				yMoveTarget = y + 8 * -dsin(lookDir);
		
				addTimesource("Attack", id, 24, bumpFunc);
				stateMachine.change("bump");
				
				endPlayerTurn(x, y, z - 16);
				return;
			}
	
	
			//Look around
			if(GetLookPressed()) {
				stateMachine.change("look");                                  //Set our state and reset our mouse position
				window_mouse_set(window_get_width()/2, window_get_height()/2);
				return;
			}
	
	
			//Turn
			dDir = 90 * ( GetLeftHeld() - GetRightHeld() );
			if(dDir != 0) {		
				lookDirInc = dDir / moveSpeedFrames;
				targetLookDir = (lookDir + dDir + 360) mod 360;
			
				addTimesource("Turn", id, moveSpeedFrames, turnFunc);
				stateMachine.change("turn");
				return;
			}	
		
		
			//Move forward and back
			dX = 32 *  dcos(lookDir) * ( GetUpHeld() - GetDownHeld() );
			dY = 32 * -dsin(lookDir) * ( GetUpHeld() - GetDownHeld() );
			if(dX != 0 || dY != 0) {
				var collis = tilemap_get_at_pixel(World.coll, x + dX, y + dY);
				var bump   = collis > 0;
				
				var entities = ds_map_keys_to_array(World.entities, []);
				for (var i = 0; i < array_length(entities); ++i) {
					var entityID = entities[i];
				    var entity   = World.entities[? entityID];
			
					if !entity.has("ImpassableComponent") continue;
			
					var entityX  = entity.get("Position", "x");
					var entityY  = entity.get("Position", "y");
			
					if (entityX == x + dX && entityY == y + dY) {
						if !entity.get("Impassable", "bumping") bump = false;
						collis = true;
					}
				}
				
				if collis {
					if !bump return;
					xMoveTarget = x + dX;
					yMoveTarget = y + dY;
				
					addTimesource("Bump",          id, moveSpeedFrames,             bumpFunc);
					addTimesource("BloodSplatter", id, moveSpeedFrames / 4, createBloodDecal);
					stateMachine.change("bump");
					
					endPlayerTurn(x, y, z - 16);
					return;
				};
		
				xMoveTarget = x + dX;
				yMoveTarget = y + dY;
				xMoveInc = dX / moveSpeedFrames;
				yMoveInc = dY / moveSpeedFrames;
			
				addTimesource("Move", id, moveSpeedFrames, moveFunc);
				stateMachine.change("move");
				
				endPlayerTurn(x + dX, y + dY, z - 16);
				return;
			}	


			//Strafe
			dX = 32 *  dcos(lookDir + 90) * ( GetStrafeLeftHeld() - GetStrafeRightHeld() );
			dY = 32 * -dsin(lookDir + 90) * ( GetStrafeLeftHeld() - GetStrafeRightHeld() );
			if(dX != 0 || dY != 0) {
				var collis = tilemap_get_at_pixel(World.coll, x + dX, y + dY);
				var bump   = collis > 0;
				
				var entities = ds_map_keys_to_array(World.entities, []);
				for (var i = 0; i < array_length(entities); ++i) {
					var entityID = entities[i];
				    var entity   = World.entities[? entityID];
			
					if !entity.has("ImpassableComponent") continue;
			
					var entityX  = entity.get("Position", "x");
					var entityY  = entity.get("Position", "y");
			
					if (entityX == x + dX && entityY == y + dY) {
						if !entity.get("Impassable", "bumping") bump = false;
						collis = true;
						break;
					}
				}
				
				if collis {
					if !bump return;
					xMoveTarget = x + dX;
					yMoveTarget = y + dY;
				
					addTimesource("Bump", id, moveSpeedFrames, bumpFunc);
					addTimesource("BloodSplatter", id, moveSpeedFrames / 4, createBloodDecal);
					stateMachine.change("bump");
					
					endPlayerTurn(x, y, z - 16);
					return;
				};
		
				xMoveTarget = x + dX;
				yMoveTarget = y + dY;
				xMoveInc = dX / moveSpeedFrames;
				yMoveInc = dY / moveSpeedFrames;
			
				addTimesource("Move", id, moveSpeedFrames, moveFunc);
				stateMachine.change("move");
				
				endPlayerTurn(x + dX, y + dY, z - 16);				
				return;
			}

	
			bobHead();
			nodHead();
			shakeHead();
		}
	})

	.add("move", {
		enter: function() {},
		update: function() {
			x += xMoveInc; y += yMoveInc;
			bobHead();
		}
	})

	.add("turn", {
		enter: function() {},
		update: function() { lookDir = (lookDir + lookDirInc + 360) mod 360 }
	})

	.add("look", {
		enter: function() {},
		update: function() {
			var mx = window_mouse_get_x(), my = window_mouse_get_y();
			var cx = window_get_width()/2, cy = window_get_height()/2;
	
			lookDirOffset -= ( mx - cx ) / 5;
			lookPitOffset += ( my - cy ) / 5;
	
			//-80 < lookPit + lookPitOffset < 80
			lookPitOffset = clamp(lookPitOffset, -80 - lookPit, 80 - lookPit);	
	
			window_mouse_set(cx, cy);
	
			if(GetLookPressed()) {
				var compundDir = (lookDir + lookDirOffset + 360) mod 360;
				lookDir = round(compundDir / 90) * 90;
				lookDirOffset = compundDir - lookDir;
		
				stateMachine.change("input");
			}
		}
	})

	.add("bump", {
		enter: function() {},
		update: function() {
			var delta = animcurve_channel_evaluate(bumpAnim, animPos / 12);
			x = lerp(xPrevious, xMoveTarget, delta);
			y = lerp(yPrevious, yMoveTarget, delta);
	
			animPos ++;
	
			bobHead();
		}
	})

//Callbacks for when states are finished [WIP]
moveFunc  = function() {
	x = xMoveTarget;
	y = yMoveTarget;
	xPrevious = x;
	yPrevious = y;
	
	var event = new Event("Step", {x: x, y: y, z: z - 16});
	event = event.fire();
	
	stateMachine.change("step");
}
turnFunc  = function() {
	lookDir = targetLookDir;
	stateMachine.change("input");
}
bumpFunc  = function() {
	x = xPrevious;
	y = yPrevious;	
	animPos = 0;

	stateMachine.change("step");
}

//Various methods for the player
createBloodDecal = function() {
	hp = max(0, hp - 1);
	var spr = sBloodDecal;
	if (hp == 0) spr = sBloodDecal_Death;
	
	var blood = instance_create_layer(xPrevious, yPrevious, "Instances", Decal);
	blood.sprite_index = spr;
	blood.lookDir      = point_direction(xPrevious, yPrevious, xMoveTarget, yMoveTarget);
	blood.image_index  = irandom_range(0, image_number - 1);
	blood.image_speed  = 0;
	blood.createMesh();
}
bobHead          = function() {
	zFromOffset = lerp(zFromOffset, 0, .5);
	xFromOffset = lerp(xFromOffset, 0, .5);
	yFromOffset = lerp(yFromOffset, 0, .5);
}
nodHead          = function() {
	if !GetInputHeld(Config.CONTROLS.NOD) { relaxHead(); return; }	
	zToOffset = lerp(zToOffset, dsin(current_time / 2)/3, .5);
}
shakeHead        = function() {
	if !GetInputHeld(Config.CONTROLS.SHAKE) { relaxHead(); return; }	
	switch(lookDir) {
		case 0:
			yToOffset = lerp(yToOffset, dsin(current_time/2)/3, .5);
			break;
		case 180:
			yToOffset = lerp(yToOffset, dsin(current_time/2)/3, .5);
			break;
		default:
			xToOffset = lerp(xToOffset, dsin(current_time/2)/3, .5);
			break;
	}
}
relaxHead        = function() {
	xToOffset = lerp(xToOffset, 0, 0.5);
	yToOffset = lerp(yToOffset, 0, 0.5);
	zToOffset = lerp(zToOffset, 0, 0.5);
}