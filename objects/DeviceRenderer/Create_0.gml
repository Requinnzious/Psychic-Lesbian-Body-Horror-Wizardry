z = 8;
model = World.dodecahedron;

render = function() {
	matrix_set(matrix_world, matrix_build(x, y, z + sin(current_time / 1000), 0, 0, sin(current_time / 5000) * 360, 5, 5, 5));
	model.submit();
}