stateMachine.update();

show_debug_message(stateMachine.get_current_state());

iui_update_io();

if !surface_exists(screenSurf) screenSurf = surface_create(surface_get_width(application_surface), surface_get_height(application_surface));
if !surface_exists(surface1)   surface1   = surface_create(surface_get_width(application_surface), surface_get_height(application_surface));
if !surface_exists(surface2)   surface2   = surface_create(surface_get_width(application_surface), surface_get_height(application_surface));
if !surface_exists(surface3)   surface3   = surface_create(surface_get_width(application_surface), surface_get_height(application_surface));

//If we're not in the lookState, we can relax our gaze
if(!stateMachine.state_is("look")) {
	lookDirOffset = lerp(lookDirOffset, 0, 0.05);
	lookPitOffset = lerp(lookPitOffset, 0, 0.05);
}

