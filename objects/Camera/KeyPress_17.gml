CRTDebugUI = !CRTDebugUI;

if CRTDebugUI {
	Config.CONTROLS.ATTACK = [
		{controlType: "Keyboard", binds: [vk_space]},
		{controlType: "Mouse",    binds: []},
		{controlType: "Gamepad",  binds: [gp_face3]}
	]
} 
else {
	Config.CONTROLS.ATTACK = [
		{controlType: "Keyboard", binds: [vk_space]},
		{controlType: "Mouse",    binds: [mb_left]},
		{controlType: "Gamepad",  binds: [gp_face3]}
	]
}