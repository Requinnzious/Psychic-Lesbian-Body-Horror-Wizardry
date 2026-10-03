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


function GetAttackHeld() {
	var inputs = Config.CONTROLS.ATTACK;
	return GetInputHeld(inputs);
}

function GetLookPressed() {
	var inputs = Config.CONTROLS.LOOK;
	return GetInputPressed(inputs);
}


function GetUpPressed() {
	var inputs = Config.CONTROLS.UP;
	return GetInputPressed(inputs);	
}
function GetDownPressed() {
	var inputs = Config.CONTROLS.DOWN;
	return GetInputPressed(inputs);	
}
function GetLeftPressed() {
	var inputs = Config.CONTROLS.TURN_LEFT;
	return GetInputPressed(inputs);	
}
function GetRightPressed() {
	var inputs = Config.CONTROLS.TURN_RIGHT;
	return GetInputPressed(inputs);	
}

function GetUpHeld() {
	var inputs = Config.CONTROLS.UP;
	return GetInputHeld(inputs);	
}
function GetDownHeld() {
	var inputs = Config.CONTROLS.DOWN;
	return GetInputHeld(inputs);	
}
function GetLeftHeld() {
	var inputs = Config.CONTROLS.TURN_LEFT;
	return GetInputHeld(inputs);	
}
function GetRightHeld() {
	var inputs = Config.CONTROLS.TURN_RIGHT;
	return GetInputHeld(inputs);	
}
function GetStrafeLeftHeld() {
	var inputs = Config.CONTROLS.STRAFE_LEFT;
	return GetInputHeld(inputs);	
}
function GetStrafeRightHeld() {
	var inputs = Config.CONTROLS.STRAFE_RIGHT;
	return GetInputHeld(inputs);	
}