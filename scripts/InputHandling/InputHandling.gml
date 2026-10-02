function GetInputPressed(inputs) {
	for (var i = 0; i < array_length(inputs); ++i) {
		var control = inputs[i];
	    switch(control.controlType) {
			case "Keyboard":
				for (var j = 0; j < array_length(control.binds); ++j) {
				    if(keyboard_check_pressed(control.binds[j]))     return true;
				}
				break;
			case "Mouse":
				for (var j = 0; j < array_length(control.binds); ++j) {
				    if(mouse_check_button_pressed(control.binds[j])) return true;
				}
				break;
			case "Gamepad":
				for (var j = 0; j < array_length(control.binds); ++j) {
				    if(gamepad_button_check_pressed(0, control.binds[j])) return true;
				}
				break;
		}
	}
	return false;
}
function GetInputHeld(inputs) {
	for (var i = 0; i < array_length(inputs); ++i) {
		var control = inputs[i];
	    switch(control.controlType) {
			case "Keyboard":
				for (var j = 0; j < array_length(control.binds); ++j) {
				    if(keyboard_check(control.binds[j]))     return true;
				}
				break;
			case "Mouse":
				for (var j = 0; j < array_length(control.binds); ++j) {
				    if(mouse_check_button(control.binds[j])) return true;
				}
				break;
			case "Gamepad":
				for (var j = 0; j < array_length(control.binds); ++j) {
				    if(gamepad_button_check(0, control.binds[j])) return true;
				}
				break;
		}
	}
	return false;
}
function GetInputReleased(inputs) {
	for (var i = 0; i < array_length(inputs); ++i) {
		var control = inputs[i];
	    switch(control.controlType) {
			case "Keyboard":
				for (var j = 0; j < array_length(control.binds); ++j) {
				    if(keyboard_check_released(control.binds[j]))     return true;
				}
				break;
			case "Mouse":
				for (var j = 0; j < array_length(control.binds); ++j) {
				    if(mouse_check_button_released(control.binds[j])) return true;
				}
				break;
			case "Gamepad":
				for (var j = 0; j < array_length(control.binds); ++j) {
				    if(gamepad_button_check_released(0, control.binds[j])) return true;
				}
				break;
		}
	}
	return false;
}


function GetConfirmPressed() {
	var inputs = Config.CONTROLS.CONFIRM;
	return GetInputPressed(inputs);
}
function GetConfirmHeld() {
	var inputs = Config.CONTROLS.CONFIRM;
	return GetInputHeld(inputs);
}

function GetTurnPressed() {
	var inputs = Config.CONTROLS.TURN;
	return GetInputPressed(inputs);
}
function GetTurnHeld() {
	var inputs = Config.CONTROLS.TURN;
	return GetInputHeld(inputs);
}
function GetTurnReleased() {
	var inputs = Config.CONTROLS.TURN;
	return GetInputReleased(inputs);
}

function GetDiagPressed() {
	var inputs = Config.CONTROLS.DIAG;
	return GetInputPressed(inputs);
}
function GetDiagHeld() {
	var inputs = Config.CONTROLS.DIAG;
	return GetInputHeld(inputs);
}

function GetMinimapPressed() {
	var inputs = Config.CONTROLS.MINIMAP;
	return GetInputPressed(inputs);
}

function GetUpPressed() {
	var inputs = Config.CONTROLS.UP;
	return GetInputPressed(inputs);	
}
function GetUpLeftPressed() {
	var inputs = Config.CONTROLS.UPLEFT;
	return GetInputPressed(inputs);	
}
function GetUpRightPressed() {
	var inputs = Config.CONTROLS.UPRIGHT;
	return GetInputPressed(inputs);	
}
function GetDownPressed() {
	var inputs = Config.CONTROLS.DOWN;
	return GetInputPressed(inputs);	
}
function GetDownLeftPressed() {
	var inputs = Config.CONTROLS.DOWNLEFT;
	return GetInputPressed(inputs);	
}
function GetDownRightPressed() {
	var inputs = Config.CONTROLS.DOWNRIGHT;
	return GetInputPressed(inputs);	
}
function GetLeftPressed() {
	var inputs = Config.CONTROLS.LEFT;
	return GetInputPressed(inputs);	
}
function GetRightPressed() {
	var inputs = Config.CONTROLS.RIGHT;
	return GetInputPressed(inputs);	
}

function GetUpHeld() {
	var inputs = Config.CONTROLS.UP;
	return GetInputHeld(inputs);	
}
function GetUpLeftHeld() {
	var inputs = Config.CONTROLS.UPLEFT;
	return GetInputHeld(inputs);	
}
function GetUpRightHeld() {
	var inputs = Config.CONTROLS.UPRIGHT;
	return GetInputHeld(inputs);	
}
function GetDownHeld() {
	var inputs = Config.CONTROLS.DOWN;
	return GetInputHeld(inputs);	
}
function GetDownLeftHeld() {
	var inputs = Config.CONTROLS.DOWNLEFT;
	return GetInputHeld(inputs);	
}
function GetDownRightHeld() {
	var inputs = Config.CONTROLS.DOWNRIGHT;
	return GetInputHeld(inputs);	
}
function GetLeftHeld() {
	var inputs = Config.CONTROLS.LEFT;
	return GetInputHeld(inputs);	
}
function GetRightHeld() {
	var inputs = Config.CONTROLS.RIGHT;
	return GetInputHeld(inputs);	
}