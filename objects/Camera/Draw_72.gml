surface_set_target(normalSurf);
draw_clear(c_black);
surface_reset_target();

surface_set_target(depthSurf);
draw_clear(c_black);
surface_reset_target();

surface_set_target(screenSurf);