var x1 = 0;
var x2 = window_get_width();
var y1 = 0;
var y2 = window_get_height();


//Draw minimap
draw_rectangle(x2 - 160, 0, x2, 160, false);
for (var i = 0; i < 160; i += TileDim) {
    for (var j = 0; j < 160; j += TileDim) {
		var xx = clamp(x / TileDim + 2 - i / TileDim, 0, array_length(World.tiles)    - 1);
		var yy = clamp(y / TileDim + 2 - j / TileDim, 0, array_length(World.tiles[0]) - 1);
		
	    var tile = World.tiles[xx][yy].tile;
		draw_sprite(sMetaTiles_Strip, tile, 128 - i + x2 - 160, 128 - j);
	}
}


//Draw enemies on minimap
for (var i = 0; i < instance_number(Enemy); ++i) {
    var enemy = instance_find(Enemy, i);
	var enemyX = floor(enemy.x / TileDim) * TileDim;
	var enemyY = floor(enemy.y / TileDim) * TileDim;
	
	if (enemyX < x - 96 || enemyY < y - 96 || enemyX > x + 64 || enemyY > y + 64) continue;
	
	var xx = (floor(x / TileDim) * TileDim) - enemyX;
	var yy = (floor(y / TileDim) * TileDim) - enemyY;
	
	draw_sprite(enemy.sprite_index, enemy.image_index, x2 - xx - 96 + 16, 160 - yy - 96 + 24);
}


//Player cursor
var cx1 = x2 - 80 -       dcos(lookDir) *  8;
var cy1 = 80      +       dsin(lookDir) * 16;
var cx2 = cx1     + lengthdir_x(16, lookDir);
var cy2 = cy1     + lengthdir_y(16, lookDir);

draw_arrow(cx1, cy1, cx2, cy2, 16);