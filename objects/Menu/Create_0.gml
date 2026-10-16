stateMachine = new SnowState("TopMenu")
	.add("TopMenu", {
		enter:  function() {
			width     = 256;
			height    = 128;
			cursorPos =   0;
			pagePos   =   0;
			
			options = [
				{str: "[scale,2]Inventory", state: "ItemMenu"},
				{str: "[scale,2]Options",   state: "OptionMenu"},
				{str: "[scale,2]Quit Game", state: "QuitGame"}
			]
		},
		update: function() {
			var dY = GetDownPressed() - GetUpPressed();
			if dY != 0 {
				Sound.playSound(SoundTypes.CURSOR);
				cursorPos = (cursorPos + dY + array_length(options)) mod array_length(options);
			}
			if GetConfirmPressed() {
				Sound.playSound(SoundTypes.CURSOR);
				stateMachine.change(options[cursorPos].state);
			}		
			if GetCancelPressed() || GetMenuPressed() {
				Camera.stateMachine.change("input");
				Sound.playSound(SoundTypes.MENU_CLOSE)
				instance_destroy();
				return;
			}
		},
		leave:  function() {}
	})
	
	.add("ItemMenu", {
		enter:  function() {
			width     = 384;
			height    = 408;		
			cursorPos =   0;
			pagePos   =   0;
			
			options = [
				{str: "[scale,2]Test Item",             colorStr: "[scale,2]Test Item",                                state: "ExitMenu"},
				{str: "[scale,2]Magic Item",            colorStr: "[scale,2][c_aqua]Magic[c_white] Item",              state: "ExitMenu"},
				{str: "[scale,2]Cursed Item",           colorStr: "[scale,2][c_red]Cursed[c_white] Item",              state: "ExitMenu"},
				{str: "[scale,2][wave]???[/wave] Item", colorStr: "[scale,2][c_yellow][wave]???[/wave][c_white] Item", state: "ExitMenu"},
				
				{str: "[scale,2]Test Item",             colorStr: "[scale,2]Test Item",                                state: "ExitMenu"},
				{str: "[scale,2]Magic Item",            colorStr: "[scale,2][c_aqua]Magic[c_white] Item",              state: "ExitMenu"},
				{str: "[scale,2]Cursed Item",           colorStr: "[scale,2][c_red]Cursed[c_white] Item",              state: "ExitMenu"},
				{str: "[scale,2][wave]???[/wave] Item", colorStr: "[scale,2][c_yellow][wave]???[/wave][c_white] Item", state: "ExitMenu"},
				
				{str: "[scale,2]Test Item",             colorStr: "[scale,2]Test Item",                                state: "ExitMenu"},
				{str: "[scale,2]Magic Item",            colorStr: "[scale,2][c_aqua]Magic[c_white] Item",              state: "ExitMenu"},
				{str: "[scale,2]Cursed Item",           colorStr: "[scale,2][c_red]Cursed[c_white] Item",              state: "ExitMenu"},
				{str: "[scale,2][wave]???[/wave] Item", colorStr: "[scale,2][c_yellow][wave]???[/wave][c_white] Item", state: "ExitMenu"},
				
				
				{str: "[scale,2][wave]???[/wave] Item", colorStr: "[scale,2][c_yellow][wave]???[/wave][c_white] Item", state: "ExitMenu"},
				{str: "[scale,2]Cursed Item",           colorStr: "[scale,2][c_red]Cursed[c_white] Item",              state: "ExitMenu"},
				{str: "[scale,2]Magic Item",            colorStr: "[scale,2][c_aqua]Magic[c_white] Item",              state: "ExitMenu"},
				{str: "[scale,2]Test Item",             colorStr: "[scale,2]Test Item",                                state: "ExitMenu"},
				
				{str: "[scale,2][wave]???[/wave] Item", colorStr: "[scale,2][c_yellow][wave]???[/wave][c_white] Item", state: "ExitMenu"},
				{str: "[scale,2]Cursed Item",           colorStr: "[scale,2][c_red]Cursed[c_white] Item",              state: "ExitMenu"},
				{str: "[scale,2]Magic Item",            colorStr: "[scale,2][c_aqua]Magic[c_white] Item",              state: "ExitMenu"},
				{str: "[scale,2]Test Item",             colorStr: "[scale,2]Test Item",                                state: "ExitMenu"},
				
				{str: "[scale,2][wave]???[/wave] Item", colorStr: "[scale,2][c_yellow][wave]???[/wave][c_white] Item", state: "ExitMenu"},
				{str: "[scale,2]Cursed Item",           colorStr: "[scale,2][c_red]Cursed[c_white] Item",              state: "ExitMenu"},
				{str: "[scale,2]Magic Item",            colorStr: "[scale,2][c_aqua]Magic[c_white] Item",              state: "ExitMenu"},
				{str: "[scale,2]Test Item",             colorStr: "[scale,2]Test Item",                                state: "ExitMenu"},
			]
		},
		update: function() {
			var dX = GetRightPressed() - GetLeftPressed();
			var dY = GetDownPressed()  - GetUpPressed();
			if dX != 0 {
				Sound.playSound(SoundTypes.CURSOR);
				pagePos = real(!pagePos);
			}
			if dY != 0 {
				Sound.playSound(SoundTypes.CURSOR);
				cursorPos = (cursorPos + dY + min(12, array_length(options))) mod min(12, array_length(options));
			}
			if GetConfirmPressed() {
				Sound.playSound(SoundTypes.USE_ITEM);
				stateMachine.change(options[cursorPos].state);
			}
			if GetCancelHeld() {
				stateMachine.change("TopMenu");
				Sound.playSound(SoundTypes.CURSOR);
				return;
			}
			
			if GetMenuPressed() {
				Camera.stateMachine.change("input");
				Sound.playSound(SoundTypes.MENU_CLOSE)
				instance_destroy();
				return;
			}
		},
		leave:  function() {}
	})
	
	.add("OptionMenu", {
		enter:  function() {
			width     = 256;
			height    = 128;
			cursorPos =   0;
			pagePos   =   0;
			
			options = [
				{str: "[scale,2]Test Option", state: "TopMenu"},
				{str: "[scale,2]Test Option", state: "TopMenu"},
				{str: "[scale,2]Test Option", state: "TopMenu"}
			]
		},
		update: function() {
			var dY = GetDownPressed() - GetUpPressed();
			if dY != 0 {
				Sound.playSound(SoundTypes.CURSOR);
				cursorPos = (cursorPos + dY + array_length(options)) mod array_length(options);
			}
			if GetConfirmPressed() {
				Sound.playSound(SoundTypes.CURSOR);
				stateMachine.change(options[cursorPos].state);
			}	
			
			if GetCancelHeld() {
				stateMachine.change("TopMenu");
				Sound.playSound(SoundTypes.CURSOR);
				return;
			}
			
			if GetMenuPressed() {
				Camera.stateMachine.change("input");
				Sound.playSound(SoundTypes.MENU_CLOSE)
				instance_destroy();
				return;
			}
		},
		leave:  function() {}
	})

	.add("ExitMenu", {
		enter:  function() {
			Camera.stateMachine.change("input");
			instance_destroy();
		}
	})

	.add("QuitGame", {
		enter:  function() {
			game_end();
		}
	})

render = function() {
	draw_set_color(c_dkgray);
	draw_set_alpha(.95);
	draw_rectangle(x, y, x + width, y + height, false);
	draw_set_color(c_white);
	draw_rectangle(x, y, x + width, y + height, true);
	draw_set_alpha(1);
	
	draw_set_halign(fa_center);
	draw_set_valign(fa_middle);
	
	var optionsOffset  = (pagePos) * 12;
	
	if array_length(options) > 12 {
		height = 440;
		var pageString = $"[fa_right][sMenuArrow, 2][scale,2] {pagePos + 1} / 2 [scale,1][sMenuArrow, 1]";
		if pagePos == 1 {
			pageString = $"[fa_right][sMenuArrow, 0][scale,2] {pagePos + 1} / 2 [scale,1][sMenuArrow, 2]";
		}
		scribble(pageString)
			.shadow(c_black, 1)
			.draw(x + width - 8, y + height - 40);
	}
	
	for (var i = 0; i < array_length(options) and i < 12; ++i) {
		var index = i + optionsOffset;
	    var _string = options[index].str;
		if variable_struct_exists(options[index], "colorStr") && i == cursorPos {
			_string = options[index].colorStr
		}
		if i != cursorPos {
			_string = "  [c_gray]" + _string;
		}
		scribble(_string)
			.shadow(c_black, 1)
			.draw(x + 16, y + 8 + (i * 32));
	}
	
	draw_set_halign(fa_left);
	draw_set_valign(fa_top);
}