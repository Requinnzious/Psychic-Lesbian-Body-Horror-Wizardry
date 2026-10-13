history = []
strings = []

textTime     =  60;
timeTilClose =  60;

log = function(_string, timer = 60, prio = 0) {
	if array_length(strings) >= 2 and prio > strings[0].prio {
		clear();
	}
	
	array_push(history, _string);
	array_push(strings, { str: _string, flagged: false, timer: timer, prio: prio })
	
	textTime     = timer;
	timeTilClose =    60;	
}

clear = function() {
	array_delete(strings, 0, array_length(strings));
}

render = function() {	
	if timeTilClose <= 0 {
		timeTileClose = 60;
		return;
	}
	
	var viewW = view_get_wport(view_current);
	var viewH = view_get_hport(view_current);
	
	var consoleHeight = 128;
	var paddingH      = 128;
	var paddingV      =  64;
	
	var consoleX = paddingH
	var consoleY = viewH - paddingV - consoleHeight
	
	draw_set_colour(c_dkgray);
	draw_set_alpha(.75);
	draw_rectangle(consoleX, consoleY, viewW - paddingH, viewH - paddingV, false);
	
	draw_set_colour(c_white);
	draw_set_alpha(1);
	draw_rectangle(consoleX, consoleY, viewW - paddingH, viewH - paddingV, true);
	
	if array_length(strings) == 0 {
		timeTilClose--;
		return;
	}
	
	timeTilClose = 60;
	
	if !strings[0].flagged {
		strings[0].flagged = true;
	}
	
	strings[0].timer --;
	if strings[0].timer <= 0 {
		array_delete(strings, 0, 1);
	}
		
	for (var i = 0; i < array_length(strings) and i < 2; ++i) {
		var _string = strings[i].str;
		scribble(_string)
			.wrap(viewW - paddingH)
			.shadow(c_black, 1)
			.draw(paddingH + 64, consoleY + 16 + (i * 48));
	}
}

log(@"[scale,2][Font1][c_aqua]Hello World");
log(@"[scale,2][Font1][wave]This[/wave] is some [rainbow]text[/rainbow] that [fnt_riffic_sdf][scale,.75]will be drawn[Font1][scale,2] to the game console");