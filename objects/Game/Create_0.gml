Init();
room_goto_next();

Steps = 0;	

GameState = new SnowState("stepPhase")
	.add("stepPhase",   {
		enter:  function() { 
			show_debug_message("Step Phase");
			
			Steps++;
			if !variable_instance_exists(id, "GameState") return;
			var keys = ds_map_keys_to_array(entityTurns);
			//WIP
			for (var i = 0; i < array_length(keys); ++i) {
			    var brain = entityTurns[? keys[i]].brain;
				brain.stateMachine.change("step");
			}
			GameState.change("inputPhase");
		},
		leave:  function() {},
		update: function() { 
			GameState.change("inputPhase")
		}
	})
	
	.add("inputPhase",  {
		enter:  function() {
			show_debug_message("Input Phase");
			
			if variable_instance_exists(id, "entityTurns") {
				ds_map_clear(entityTurns);
				return;
			}
			entityTurns = ds_map_create();
		},
		leave:  function() {},
		update: function() {
			var keys = ds_map_keys_to_array(entityTurns);			
			if array_length(keys) == 0 return;
		}
	})
	
	.add("itemPhase",   {
		enter:  function() {},
		leave:  function() {},
		update: function() {}
	})
	
	.add("movePhase",   {
		enter:  function() {
			show_debug_message("Move Phase");
		},
		leave: function()  {},
		update: function() {
			var keys = ds_map_keys_to_array(entityTurns);		
			
			var turnComplete = true;
			
			//If any of our brains have an "active" state - != "wait" - the phase isn't over
			for (var i = 0; i < array_length(keys); ++i) {
			    var brain = entityTurns[? keys[i]].brain;
				if !brain.stateMachine.state_is("wait") {
					turnComplete = false;
					break;
				}
			}			
			if !turnComplete return;
			
			var _attackQueue = [];
			
			with Brain {
				if movePoints <= 0 continue;
				array_push(_attackQueue, id);
			}
			
			attackQueue = _attackQueue;
			
			//Go to next state
			GameState.change("attackPhase")
		}
	})
	
	.add("attackPhase", {
		enter:  function() { 
			show_debug_message("Attack Phase");
			if array_length(attackQueue) == 0 return;
			
			var actingBrain = attackQueue[0];
			with actingBrain {
				var taunt = random(100) > 25;
				
				if parentEntity.get("TauntSprite", "taunting") taunt = false;
				
				
				
				if taunt {
					parentEntity.addComponent("BidirectionalCrit")
					stateMachine.change("taunt");
				
					var ts = time_source_create(time_source_game, AttackFrames, time_source_units_frames, bumpFunc);
					time_source_start(ts);
					
					return;
				}
				
				xPrevious = x;
				yPrevious = y;
				xTarget = Camera.x;
				yTarget = Camera.y;
			
				animPos = 0;
			
				stateMachine.change("bump");
				
				var ts = time_source_create(time_source_game, AttackFrames, time_source_units_frames, bumpFunc);
				time_source_start(ts);
				
				ts = time_source_create(time_source_game, AttackFrames / 2, time_source_units_frames, 
					function() {
						var hitDie = "1d3";
						var sound  = SoundTypes.HIT1;
						var crit   = false;
						
						var event = new Event("DealMeleeDamage")
						event = parentEntity.fireEvent(event);
						if variable_struct_exists(event.params, "hitDie") hitDie = event.params.hitDie;
						if variable_struct_exists(event.params, "sound")  sound  = event.params.sound;
						if variable_struct_exists(event.params, "crit")   crit   = event.params.crit;
						delete event;
						
						var damageRoll = roll(hitDie)
						
						event = new Event("TakeDamage", {amount: damageRoll + (damageRoll * crit)})
						event = SixOfCups.fireEvent(event);
						delete event;
						
						Sound.playSound(sound);
						Camera.screenShake          =  4 + (8 * crit);
						Camera.screenShakeIntensity =  1 + (1 * crit);
					}
				);
				time_source_start(ts);
			}
			
			//show_debug_message(attackQueue[0].stateMachine.get_current_state());
		},
		leave: function()  {},
		update: function() {
			if array_length(attackQueue) == 0 {
				GameState.change("endPhase");
				return;
			}
			
			var actingBrain = attackQueue[0];
			if actingBrain.stateMachine.get_current_state() != "wait" return;
			
			array_delete(attackQueue, 0, 1);
			
			if array_length(attackQueue) == 0 {
				GameState.change("endPhase");
				return;
			}
			
			actingBrain = attackQueue[0];
			with actingBrain {
				xPrevious = x;
				yPrevious = y;
				xTarget   = lerp(x, Camera.x, .9);
				yTarget   = lerp(y, Camera.y, .9);
			
				animPos = 0;
			
				stateMachine.change("bump");
				
				var ts = time_source_create(time_source_game, MoveFrames, time_source_units_frames, bumpFunc);
				time_source_start(ts);
				
				ts = time_source_create(time_source_game, AttackFrames / 2, time_source_units_frames, 
					function() {
						var hitDie = "1d3";
						var sound = SoundTypes.HIT1;
						var crit  = false;
						
						var event = new Event("DealMeleeDamage")
						event = parentEntity.fireEvent(event);
						hitDie = event.params.hitDie;
						if variable_struct_exists(event.params, "sound")  sound  = event.params.sound;
						if variable_struct_exists(event.params, "crit")   crit   = event.params.crit;
						delete event;
						
						var event = new Event("TakeDamage", {amount: roll(hitDie) * (2 * crit)})
						event = SixOfCups.fireEvent(event);
						delete event;
						
						Sound.playSound(sound);
						Camera.screenShake          =  4 + (8 * crit);
						Camera.screenShakeIntensity =  1 + (1 * crit);
					}
				);
				time_source_start(ts);
			}
		}
	})
	
	.add("endPhase",    {
		enter:  function() {
			show_debug_message("End Phase\n");
			GameState.change("stepPhase");
		},
		leave: function()  {},
		update: function() {
			GameState.change("stepPhase")
		}
	})
	
	
subscribe("PlayerTurn", id);
fireEvent = function(_event) {
	switch _event.type {
		case "PlayerTurn":
			with Brain {
				mp_grid_add_cell(World.aStar, x/TileDim, y/TileDim);
				movePoints = 100;
			}
		
			var moveBrains = new Event("Brain_Move", _event.params);
			moveBrains = moveBrains.fire();
			delete moveBrains;
			
			with Brain {
				mp_grid_clear_cell(World.aStar, x/TileDim, y/TileDim);
			}
			
			GameState.change("movePhase");
			break;
	}
	return _event;
}


SixOfCups = new Entity(PlayerName)
	.addComponent("Physics",       { maxFlash:   24, hitDie: "1d6+4" })
	.addComponent("Impassable",    { bumping: false })
	.addComponent("Health",        { hp:         24 })
	.addComponent("Position",      { x:          96, y:     96, z:  0 })
	.addComponent("Transform",     { x:           0, y:      0, z: 16 })
	.addComponent("HealthRegen")
		
	//.addComponent("MiniMapSprite", {sprite: sWizard})

SixOfCups.fireEvent(EntityCreateEvent);
