state(); //This executes whatever function is assigned to state

//Head Nod!!!
if(GetInputHeld(Config.CONTROLS.NOD)) {
	zToOffset = lerp(zToOffset, dsin(current_time / 2)/3, .5);
} 
else {
	zToOffset = lerp(zToOffset, 0, 0.5);
}

//Head shake!!
if(GetInputHeld(Config.CONTROLS.SHAKE)) {
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
else {
	xToOffset = lerp(xToOffset, 0, 0.5);
	yToOffset = lerp(yToOffset, 0, 0.5);
}

//If we're not in the lookState, we can relax our gaze
if(state != lookState) {
	lookDirOffset = lerp(lookDirOffset, 0, 0.05);
	lookPitOffset = lerp(lookPitOffset, 0, 0.05);
}
