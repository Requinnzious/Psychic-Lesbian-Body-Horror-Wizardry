function roll_dice(numDice, numSides) {
	var total = 0;
	repeat(numDice) {
		total += irandom_range(1, numSides);
	}
	return total;
}

function roll(dNotation) {
	var str = string_split(dNotation, "|+", true);
	if (array_length(str) == 2) {
		return roll(str[0]) + roll(str[1]);
	}
	
	str = string_split(dNotation, "|-", true);
	if (array_length(str) == 2) {
		return roll(str[0]) - roll(str[1]);
	}
	
	
	str = string_split(dNotation, "d", true);
	if (array_length(str) != 2) {
		str = string_split(dNotation, "D", true);
		if (array_length(str) != 2) {
			return "Invalid dice notation - expects 'XdY' as a string ( ex. 2d6 )"
		}
	}
	
	
	var mods = string_split(str[1], "+");
	if (array_length(mods) == 2) {
		return roll_dice(str[0], mods[0]) + real(mods[1]);
	}
	
	mods = string_split(str[1], "-");
	if (array_length(mods) == 2) {
		return roll_dice(str[0], mods[0]) - real(mods[1]);
	}
	
	mods = string_split(str[1], "*");
	if (array_length(mods) == 2) {
		return roll_dice(str[0], mods[0]) * real(mods[1]);
	}
	
	mods = string_split(str[1], "/");
	if (array_length(mods) == 2) {
		return roll_dice(str[0], mods[0]) / real(mods[1]);
	}
	
	mods = string_split(str[1], "^");
	//show_debug_message(mods)
	if (array_length(mods) == 2) {
		return power( roll_dice(str[0], mods[0]), real(mods[1]) );
	}
	
	return roll_dice(str[0], str[1]);
}