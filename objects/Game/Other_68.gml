if async_load[? "type"] == network_type_connect {
	show_debug_message(async_load[? "result"]);
}

if async_load[? "type"] == network_type_data {	
	var buffer  = async_load[? "buffer"];
	var data    = json_parse(buffer_read(buffer, buffer_string));
	
	show_debug_message(data.type);
	
	switch(data.type) {
		default:
			show_message_async(data.msg);
			break;
	}
};
