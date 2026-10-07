globalvar MessageType;

MessageType = {
	System:        "system",
	PlayerMessage: "playermessage"
}

function sendMessage(data) {
	var buff = buffer_create(1, buffer_grow, 1);

	buffer_write(buff, buffer_text, json_encode(data));
	network_send_raw(WebSocket, buff, buffer_tell(buff));
	ds_map_destroy(data);
}