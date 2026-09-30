globalvar vFormat;

#region Define vertex format
	vertex_format_begin();
	vertex_format_add_position_3d();
	vertex_format_add_normal();
	vertex_format_add_texcoord();
	vertex_format_add_color();
	vFormat = vertex_format_end();
#endregion

function addVertex(buff, pos, norm, uv, col, a) {
	vertex_position_3d(buff,  pos[0],  pos[1],  pos[2]);
	vertex_normal(buff,       norm[0], norm[1], norm[2]);
	vertex_texcoord(buff,     uv[0],   uv[1]);
	vertex_colour(buff,       col,     a);
}