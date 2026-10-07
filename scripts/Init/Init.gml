
function Init(){
	globalvar WebSocket;
	WebSocket = network_create_socket(network_socket_ws);
	network_connect_raw_async(WebSocket, "ws://minipc-owkhu.taile068a6.ts.net/?room=the Lobby&user=Six of Cups", 3000);
	
	globalvar Config;
	Config = init_config();
	
	#region Event Globals
		globalvar EventUUIDIncrement;
		globalvar EntityCreateEvent, EntityDestroyEvent, EntityRenderEvent;
	
		EventUUIDIncrement = 0;
		EntityCreateEvent  = new Event("Create",  {});
		EntityDestroyEvent = new Event("Destroy", {});
		EntityRenderEvent  = new Event("Render",  {x: 0, y: 0, z: 0});
	#endregion
	
	#region Entity Globals
		globalvar MoveFrames;
		globalvar EntityUUID;
		MoveFrames = 16;
		EntityUUID =  0;
		
		globalvar PlayerName;
		PlayerName = "Six of Cups";
		
		globalvar SixOfCups;
	#endregion
	
	#region TimeSources
		globalvar TimeSources;
		TimeSources = [];
	#endregion
	
	#region Rendering Globals
		globalvar DefaultTexture;
		DefaultTexture = sprite_get_texture(sPathTexture, 0);
	#endregion
}