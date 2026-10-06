Init();
room_goto_next();

Steps = 0;

GameState = new SnowState("stepPhase")
	.add("stepPhase",   {
		enter:  function() { 
			Steps++;
			if variable_instance_exists(id, "GameState") GameState.change("inputPhase");
		},
		leave:  function() {},
		update: function() { 
			GameState.change("inputPhase")
		}
	})
	
	.add("inputPhase",  {
		enter:  function() {
			//show_debug_message("We're reading inputs now")
		},
		leave:  function() {},
		update: function() {
			GameState.change("endPhase")
		}
	})
	
	.add("itemPhase",   {
		enter:  function() {},
		leave:  function() {},
		update: function() {}
	})
	
	.add("movePhase",   {
		enter:  function() {},
		leave: function()  {},
		update: function() {}
	})
	
	.add("attackPhase", {
		enter:  function() {},
		leave: function()  {},
		update: function() {}
	})
	
	.add("endPhase",    {
		enter:  function() {
			//show_debug_message("End of turn\n")
		},
		leave: function()  {},
		update: function() {
			GameState.change("stepPhase")
		}
	})
	

SixOfCups = new Entity("Six of Cups")
	.addComponent("Physics",       { maxFlash:   24 })
	.addComponent("Impassable",    { bumping: false })
	.addComponent("Health",        { hp:         24, maxHP: 24 })
	.addComponent("Position",      { x:          96, y:     96, z:  0 })
	.addComponent("Transform",     { x:           0, y:      0, z: 16 })
		
	//.addComponent("MiniMapSprite", {sprite: sWizard})

SixOfCups.fireEvent(EntityCreateEvent);
show_debug_message(SixOfCups);