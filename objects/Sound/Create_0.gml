globalvar SoundTypes;
enum SoundTypes {
	SWING,
	CLAW,
	
	HIT,
	HIT1,
	CRIT,
	
	SLIME,
	
	STEP_DIRT,
	STEP_STONE,
	
	GRASS,
	ILLUSION
}

audio_play_sound(ostCity, 0, true);

playSound = function(soundType = -1) {
	var sound, gainMult = 1;
	switch(soundType) {
		case SoundTypes.SWING:
			sound = audio_play_sound(seSwing, 6,  false, 1, 0, random_range(.9, 1.1));
			gainMult = 2
			break;
		case SoundTypes.CLAW:
			sound = audio_play_sound(seClaw,  6,  false, 1, 0, random_range(.9, 1.1));
			break;
		
		
		case SoundTypes.HIT:
			sound = audio_play_sound(seHit,   5,  false, 1, 0, random_range(.9, 1.1));
			break;
		case SoundTypes.HIT1:
			sound = audio_play_sound(seHit1,  5,  false, 1, 0, random_range(.9, 1.1));
			break;
		case SoundTypes.CRIT:
			sound = audio_play_sound(seCrit,  5,  false, 1, 0, random_range(.9, 1.1));
			break;
		
		
		case SoundTypes.SLIME:
			sound = audio_play_sound(seHit,   5,  false, 1, 0, random_range(.9, 1.1));
			audio_sound_gain(sound, Config.SOUND.SFXVOLUME / 100 * .8, 0);
			
			sound = audio_play_sound(seSlime, 4,  false, 1, 0, random_range(.9, 1.1));
			gainMult = .6;
			break;			
		
		
		case SoundTypes.STEP_DIRT:
			sound = audio_play_sound(choose(seStepDirt, seStepDirt1), 10, false, 1, 0, random_range(.9, 1.1));
			gainMult = .6;
			break;
		case SoundTypes.STEP_STONE:
			sound = audio_play_sound(choose(seStepDirt, seStepDirt1), 10, false, 1, 0, random_range(.9, 1.1));
			audio_sound_gain(sound, Config.SOUND.SFXVOLUME / 100 * .2, 0);
			sound = audio_play_sound(seDrip, 10, false, 1, 0, random_range(.6, 1.4));
			gainMult = .4;
			break;
			
		case SoundTypes.GRASS:
			sound = audio_play_sound(choose(seWings, seWings1), 10, false, 1, 0, random_range(.7, .8));
			gainMult = .8;
			break;
			
		case SoundTypes.ILLUSION:
			sound = audio_play_sound(seHeal,      5,  false, 1, 0, random_range(.2, .35));
			audio_sound_gain(sound, Config.SOUND.SFXVOLUME / 100 * .7, 0);
			sound = audio_play_sound(seLevelUp,   5,  false, 1, 0, random_range(1, 1.35));
			audio_sound_gain(sound, Config.SOUND.SFXVOLUME / 100 * .3, 0);
			sound = audio_play_sound(seWings, 4,  false, 1, 0, random_range(.5, .6));
			audio_sound_gain(sound, Config.SOUND.SFXVOLUME / 100 * .3, 0);
			
			sound = audio_play_sound(seWings, 4,  false, 1, 0, random_range(.075, .1));
			gainMult = .9;
			break;		
	}
	
	audio_sound_gain(sound, min(1, Config.SOUND.SFXVOLUME / 100 * gainMult), 0);
	
}