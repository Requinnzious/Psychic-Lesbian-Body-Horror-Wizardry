function configData(dataType, data) constructor {
	dataType = dataType;
	data = data;
}

function init_config(){	
	//Here we initialize all the data for the config settings
	#region Controls
	
	#region General
		
	var confirmInput = [
		{controlType: "Keyboard", binds: [vk_enter, vk_space, vk_numpad5, vk_decimal]},
		{controlType: "Mouse",    binds: [mb_left]},
		{controlType: "Gamepad",  binds: [gp_face1]}
	];
	
	var cancelInput = [
		{controlType: "Keyboard", binds: [vk_escape, vk_backspace, vk_numpad0]},
		{controlType: "Mouse",    binds: [mb_right]},
		{controlType: "Gamepad",  binds: [gp_face2]}
	];
	
	var menuInput = [
		{controlType: "Keyboard", binds: [vk_escape,    ord("I")]},
		{controlType: "Mouse",    binds: [mb_side1]},
		{controlType: "Gamepad",  binds: [gp_face3]}
	];
	
	var minimapInput = [
		{controlType: "Keyboard", binds: [vk_tab,    ord("M")]},
		{controlType: "Mouse",    binds: []},
		{controlType: "Gamepad",  binds: [gp_select]}
	];
	
	var turnInput = [
		{controlType: "Keyboard", binds: [vk_shift]},
		{controlType: "Mouse",    binds: [mb_side2]},
		{controlType: "Gamepad",  binds: [gp_face4]}
	];
	
	var diagInput = [
		{controlType: "Keyboard", binds: [vk_control]},
		{controlType: "Mouse",    binds: []},
		{controlType: "Gamepad",  binds: [gp_paddler]}
	];
	
	#endregion
	
	#region Directional
	
	var upInput = [
		{controlType: "Keyboard", binds: [vk_up, ord("W")]},
		{controlType: "Mouse",    binds: []},
		{controlType: "Gamepad",  binds: [gp_padu]}
	]
	
	var downInput = [
		{controlType: "Keyboard", binds: [vk_down, ord("S")]},
		{controlType: "Mouse",    binds: []},
		{controlType: "Gamepad",  binds: [gp_padd]}
	]
	
	var leftInput = [
		{controlType: "Keyboard", binds: [vk_left, ord("A")]},
		{controlType: "Mouse",    binds: []},
		{controlType: "Gamepad",  binds: [gp_padl]}
	]
	
	var rightInput = [
		{controlType: "Keyboard", binds: [vk_right, ord("D")]},
		{controlType: "Mouse",    binds: []},
		{controlType: "Gamepad",  binds: [gp_padr]}
	]
	
	var upLeftInput = [
		{controlType: "Keyboard", binds: [vk_home]},
		{controlType: "Mouse",    binds: []},
		{controlType: "Gamepad",  binds: []}
	]
	
	var upRightInput = [
		{controlType: "Keyboard", binds: [vk_pageup]},
		{controlType: "Mouse",    binds: []},
		{controlType: "Gamepad",  binds: []}
	]
	
	var downLeftInput = [
		{controlType: "Keyboard", binds: [vk_end]},
		{controlType: "Mouse",    binds: []},
		{controlType: "Gamepad",  binds: []}
	]
	
	var downRightInput = [
		{controlType: "Keyboard", binds: [vk_pagedown]},
		{controlType: "Mouse",    binds: []},
		{controlType: "Gamepad",  binds: []}
	]
	
	#endregion

	#endregion

	var controls = {
		CONTROLTYPE: "Mouse",
		CONFIRM: confirmInput,
		CANCEL: cancelInput,
		MENU: menuInput,
		MINIMAP: minimapInput,
		TURN: turnInput,
		DIAG: diagInput,
		UP: upInput,
		DOWN: downInput,
		LEFT: leftInput,
		RIGHT: rightInput,
		UPLEFT: upLeftInput,
		UPRIGHT: upRightInput,
		DOWNLEFT: downLeftInput,
		DOWNRIGHT: downRightInput
	};

	#region Sound
	
	var masterVolume = 100;
	var bgmVolume    =  80;
	var sfxVolume    =  60;
	
	#endregion

	var sound = {
		MASTERVOLUME: masterVolume,
		BGMVOLUME: bgmVolume,
		SFXVOLUME: sfxVolume
	}

	#region Graphics
	
	#endregion

	//graphics settings struct

	#region Gameplay
	
	var gameplay = {
		CLICKTOMOVE: true
	}
	
	#endregion
	
	//gameplay settings struct
	
	
	var settings = {CONTROLS: controls, SOUND: sound, GAMEPLAY: gameplay};
	
	return settings;

	
}


