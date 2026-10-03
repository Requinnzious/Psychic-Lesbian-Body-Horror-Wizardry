z     = 0;
flash = 0;

hp    = 3;
maxHP = 3;

render = function() {	
	//Debug Djikstra
	var xx = floor(x / World.meshTileDim);
	var yy = floor(y / World.meshTileDim);
	var dist = Camera.djikstra[xx][yy]
	matrix_set(matrix_world, matrix_build(x + 16, y + 16, z + 3, 90, 90, Camera.lookDir, 1, 1, 1));
	
	draw_set_halign(fa_center);
	draw_set_valign(fa_bottom);
	draw_text(0, 0, dist)
	draw_set_halign(fa_left);
	draw_set_valign(fa_top);
	matrix_set(matrix_world, matrix_build_identity());
}