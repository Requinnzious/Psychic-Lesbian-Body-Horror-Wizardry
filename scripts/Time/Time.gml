function TimeSource(name, owner, countdownFrames, callback, loop = false) constructor {
	self.name        = name;
	self.owner       = owner;
	self.totalFrames = countdownFrames;
	self.frames      = countdownFrames;
	self.callback    = callback;
	self.loop        = loop;
}

function updateTimesources() {
	for (var i = array_length(TimeSources) - 1; i >= 0; --i) {
	    var timer = TimeSources[i];
		timer.frames--;
		
		if(timer.frames <= 0) {
			if(instance_exists(timer.owner)) timer.callback(timer.owner);
			delete TimeSources[i];
			array_delete(TimeSources, i, 1);
		}
	}
}

function getTimesource(name) {
	for (var i = 0; i < array_length(TimeSources); ++i) {
	    if(TimeSources[i].name != name) continue;
		return TimeSources[i];
	}
}

function addTimesource(name, owner, countdown, callback, loop = false) {
	var ts = new TimeSource(name, owner, countdown, callback, loop);
	array_push(TimeSources, ts);
}