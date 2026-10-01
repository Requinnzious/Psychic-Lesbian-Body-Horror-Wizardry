function draw_sprite_billboard(sprite, subimage, xx, yy, zz, color = c_white) {
	shader_set(shBillboard);
	matrix_set(matrix_world, matrix_build(xx, yy, zz, 0, 0, 0, 1, 1, -1));
	draw_sprite_ext(sprite, subimage, 0, 0, 1, 1, 0, color, 1);
	shader_reset();
}