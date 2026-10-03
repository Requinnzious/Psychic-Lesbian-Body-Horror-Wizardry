stateMachine.update();

//If we're not in the lookState, we can relax our gaze
if(!stateMachine.state_is("look")) {
	lookDirOffset = lerp(lookDirOffset, 0, 0.05);
	lookPitOffset = lerp(lookPitOffset, 0, 0.05);
}
