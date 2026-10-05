// Script assets have changed for v2.3.0 see
// https://help.yoyogames.com/hc/en-us/articles/360005277377 for more information
function Init(){
	
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
		MoveFrames = 12;
		EntityUUID =  0;
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