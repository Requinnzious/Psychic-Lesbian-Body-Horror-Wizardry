z     = 0;
flash = 0;

hp    = 3;
maxHP = 3;

update = function() {
	flash = max(0, flash - 1);
	if flash - 1 == 0 {
		image_index = 0;
		if hp == 0 instance_destroy();
	}
}

takeDamage = function(amount) {
	hp    = max(0, hp - amount);
	flash = 24 + (12 * hp == 0);
	image_index = 1;
}

render = function() {
	if ((flash mod 6) > 1) return;
	var col = c_white;
	if (flash) > 3 col = #ff00ff;
	if (flash) > 4 col = #aa00ff;
	if (flash) > 5 col = #0000ff;
	if (flash) > 6 col = #00ff00;
	if (flash) > 7 col = #ffff00;
	if (flash) > 8 col = #ffaa00;
	if (flash) > 9 col = #ff0000;
	draw_sprite_billboard(sprite_index, image_index, x + 16, y + 16, z, col);
}