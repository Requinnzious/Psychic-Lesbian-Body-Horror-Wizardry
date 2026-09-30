draw_set_colour(c_dkgray);

//Compass
switch(lookDir) {
	case 0:
		draw_text(16, 16, "N S");
		draw_set_color(c_white);
		draw_text(16, 16, " E ");
		break;
	case 90:
		draw_text(16, 16, "W E");
		draw_set_color(c_white);
		draw_text(16, 16, " N ");
		break;
	case 180:
		draw_text(16, 16, "S N");
		draw_set_color(c_white);
		draw_text(16, 16, " W ");
		break;
	case 270:
		draw_text(16, 16, "E W");
		draw_set_color(c_white);
		draw_text(16, 16, " S ");
		break;
}

