function configData(dataType, data) constructor {
	dataType = dataType;
	data = data;
}

function init_config(){
	#region Controls
		#region General	
			var attackInput = [
				{controlType: "Keyboard", binds: [vk_space]},
				{controlType: "Mouse",    binds: [mb_left]},
				{controlType: "Gamepad",  binds: [gp_face3]}
			]
			var lookInput = [
				{controlType: "Keyboard", binds: [ord("V")]},
				{controlType: "Mouse",    binds: [mb_right]},
				{controlType: "Gamepad",  binds: [gp_stickr]}
			]
			var nodInput = [
				{controlType: "Keyboard", binds: [ord("X")]},
				{controlType: "Mouse",    binds: []},
				{controlType: "Gamepad",  binds: [gp_shoulderrb]}
			]
			var shakeInput = [
				{controlType: "Keyboard", binds: [ord("Z")]},
				{controlType: "Mouse",    binds: []},
				{controlType: "Gamepad",  binds: [gp_shoulderlb]}
			]
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
		
			var strafeLeftInput = [
				{controlType: "Keyboard", binds: [vk_home, ord("Q")]},
				{controlType: "Mouse",    binds: []},
				{controlType: "Gamepad",  binds: [gp_shoulderl]}
			]
	
			var strafeRightInput = [
				{controlType: "Keyboard", binds: [vk_pageup, ord("E")]},
				{controlType: "Mouse",    binds: []},
				{controlType: "Gamepad",  binds: [gp_shoulderr]}
			]
		#endregion
		
		var controls = {
			CONTROLTYPE: "Mouse",
			ATTACK:       attackInput,
			LOOK:         lookInput,
			NOD:          nodInput,
			SHAKE:        shakeInput,
			UP:           upInput,
			DOWN:         downInput,
			TURN_LEFT:    leftInput,
			TURN_RIGHT:   rightInput,
			STRAFE_LEFT:  strafeLeftInput,
			STRAFE_RIGHT: strafeRightInput,
		};
	#endregion
	
	#region Sound
		var masterVolume = 100;
		var bgmVolume    =  80;
		var sfxVolume    =  60;
		var sound = {
			MASTERVOLUME: masterVolume,
			BGMVOLUME: bgmVolume,
			SFXVOLUME: sfxVolume
		}
	#endregion
	
	#region Graphics	
	#endregion
	
	#region Gameplay	
	#endregion	
		
	return {CONTROLS: controls, SOUND: sound};
}
