function setEventUUID() {
	var _id = EventUUIDIncrement;
	EventUUIDIncrement ++;
	return _id;
}

function Event(_type, _params = {}) constructor {
	uuid    = setEventUUID();
	type    = _type;
	params  = _params;
	
	handled = false;
	
	fire = function(eventBus = oEventManager.eventBus) {
		var arrLen = array_length(eventBus[? type]);
		var _event = self;
		for (var i = 0; i < arrLen; ++i) {
			var entity = eventBus[? type][i];
		    _event = entity.fireEvent(_event);
			if _event.handled return _event;
		}
		return _event;
	}
	
}

function subscribe(_type, _id, eventBus = oEventManager.eventBus) {
	if !ds_map_exists(eventBus, _type) ds_map_add(eventBus, _type, []);
	array_push(eventBus[? _type], _id);
}

function unsubscribe(_type, _id, eventBus = oEventManager.eventBus) {
	if !ds_map_exists(eventBus, _type) return;
	
	var subscribers = eventBus[? _type];
	
	var arrLen = array_length(subscribers);
	
	for (var i = 0; i < arrLen; ++i) {
	    if (subscribers[i] == _id)  {
			array_delete(subscribers, i, 1);
			if arrLen == 1 ds_map_delete(eventBus, _type);
			return;
		}
	}
}
