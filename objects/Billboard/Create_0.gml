z = 0;

render = function() {
	var fract = 500;
	if sprite_index == sBBGrass_Tall fract = 400;
	draw_sprite_billboard(sprite_index, image_index, x, y, z, current_time/fract);
}