function draw_sprite_billboard(sprite, subimage, xx, yy, zz, windSpeed = 0) {
	shader_set(shBillboard);
	shader_set_uniform_f(shader_get_uniform(shBillboard, "windSpeed"), windSpeed);
	matrix_set(matrix_world, matrix_build(xx, yy, zz, 0, 0, 0, 1, 1, -1));
	draw_sprite_ext(sprite, subimage, 0, 0, 1, 1, 0, c_white, 1);
	shader_reset();
}