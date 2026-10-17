updateTimesources();

if keyboard_check_pressed(vk_enter) {
	if   animName == "ArmsRig|guard_idle" {animName = "ArmsRig|relax";}
	else animName  = "ArmsRig|guard_idle";
}