var data = ds_map_create();

data[? "type"] = MessageType.PlayerMessage;
data[? "room"] = "Lobby";
data[?  "msg"] = "Hello World!";

sendMessage(data);