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
			show_debug_message("We're reading inputs now")
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
			show_debug_message("End of turn\n")
		},
		leave: function()  {},
		update: function() {
			GameState.change("stepPhase")
		}
	})
	
