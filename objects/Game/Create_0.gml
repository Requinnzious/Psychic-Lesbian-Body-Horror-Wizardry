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
			
			
			
			//Go to next state
			GameState.change("attackPhase")
		}
	})
	
	.add("attackPhase", {
		enter:  function() { 
			show_debug_message("Attack Phase");
			with Brain {
				if movePoints <= 0 continue;
				
				show_debug_message($"Entity {parentEntity.uuid} ({parentEntity.entityName}) wants to attack Six of Cups")
			}
		},
		leave: function()  {},
		update: function() {
			//var dirty = false;
			//with Brain {
			//	if movePoints <= 0 continue;
			//	dirty = true;
			//	
			//	show_debug_message($"Entity {parentEntity.uuid} ({parentEntity.entityName}) wants to attack Six of Cups")
			//}
			//if dirty //return;
			GameState.change("endPhase");
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
	.addComponent("Physics",       { maxFlash:   24 })
	.addComponent("Impassable",    { bumping: false })
	.addComponent("Health",        { hp:         24, maxHP: 24 })
	.addComponent("Position",      { x:          96, y:     96, z:  0 })
	.addComponent("Transform",     { x:           0, y:      0, z: 16 })
		
	//.addComponent("MiniMapSprite", {sprite: sWizard})

SixOfCups.fireEvent(EntityCreateEvent);
