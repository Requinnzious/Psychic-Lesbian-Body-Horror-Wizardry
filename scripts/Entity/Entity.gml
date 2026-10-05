function Entity(name = "") constructor {
	uuid = ++EntityUUID;
	
	entityName    = name;
	
	components    =   [];
	subscriptions =   [];
	
	addComponent = function(componentName, args = {}) {
		var component = constructComponent(componentName + "Component", args);
		component.parent = uuid;
		array_push( components, component );
		return component;
	}
	
	removeComponent = function(componentName) {
		for (var i = 0; i < array_length(components); ++i) {
			var component = components[i];
		    if component.componentName == componentName + "Component" {
				delete component;
				array_delete(components, i, 1);
				return;
			}
		}
	}
	
	//insertComponent = function(componentName, index, args = {}) {
	//	array_insert( components, index, constructComponent(componentName, args) );
	//}
	
	has = function(componentName) {
		for (var i = 0; i < array_length(components); ++i) {
		    if(components[i].componentName == componentName) return true;
		}
		return false;
	}
	
	get = function(componentName, componentMemberName) {
		for (var i = 0; i < array_length(components); ++i) {
		    if (components[i].componentName != componentName + "Component") continue;
			if !variable_struct_exists(components[i], componentMemberName) return undefined;
			return variable_struct_get(components[i], componentMemberName);
		}
		return undefined;
	}
	
	listen = function(eventName) {
		subscribe(eventName, self);
		array_push(subscriptions, eventName);
	}
	
	mute   = function(eventName) {
		unsubscribe(eventName, self);
	}
	
	fireEvent = function(_event) {
		//var arrLen = array_length(components);
		for (var i = 0; i < array_length(components); ++i) {
		    var component = components[i];
			_event = component.fireEvent(_event);
		}
		return _event;
	}
	
	destroy = function() {
		for (var i = 0; i < array_length(subscriptions); ++i) {
		    mute(subscriptions[i]);
		}
		var event = fireEvent(new Event("Death", {}));
		var _uuid = uuid;
		with Brain {
			if parentEntity.uuid == _uuid destroy();
		}
	}
	
}

function destroyEntity(entity) {
	if entity == undefined return;
	entity.fireEvent(EntityDestroyEvent);
	ds_map_delete(World.entities, entity.uuid);
	entity.destroy();
	if variable_struct_exists(entity, "brain") {
		entity.brain.destroy();
		delete entity.brain;
	}
	delete entity;
}

function Component(c_Name) constructor {
	componentName = c_Name;
	
	getParent = function() {
		return World.entities[? parent]
	}
	
	fireEvent = function(_event) {
		switch(_event.type) {
			default:
				show_debug_message(_event);
				break;
		}
		return _event;
	}
}
function constructComponent(componentName, args = {}) {
	var func = variable_instance_get(global, componentName);
	var struct = new func(componentName);
	var keys = struct_get_names(args);
	var numKeys = array_length(keys);
	
	if numKeys == 0 return struct;
	for (var i = 0; i < numKeys; ++i) {
	    if variable_struct_exists(struct, keys[i]) {
			variable_struct_set(struct, keys[i], variable_struct_get(args, keys[i]));
		}
	}
	return struct;
}

function ArmorComponent(c_Name) : Component(c_Name) constructor {
	armorValue = 2;
	fireEvent = function(_event) {
		switch(_event.type) {
			case "TakeDamage":
				_event.params.amount = max(0, _event.params.amount - armorValue);
				break;
		}
		return _event;
	}
}
function BillboardMeshComponent(c_Name) : Component(c_Name) constructor {
	other.listen("Render");
	
	color = c_white;
	
	buildMesh = function(color) {
		mesh = vertex_create_buffer();
		
		vertex_begin(mesh, vFormat);
		addVertex(mesh, [-width/2, 0, height], [0, 1, 0], [0, 0], color, 1);
		addVertex(mesh, [ width/2, 0, height], [0, 1, 0], [1, 0], color, 1);
		addVertex(mesh, [ width/2, 0,      0], [0, 1, 0], [1, 1], color, 1);
		addVertex(mesh, [-width/2, 0, height], [0, 1, 0], [0, 0], color, 1);
		addVertex(mesh, [ width/2, 0,      0], [0, 1, 0], [1, 1], color, 1);
		addVertex(mesh, [-width/2, 0,      0], [0, 1, 0], [0, 1], color, 1);
		vertex_end(mesh);
	}
	
	rebuildMesh = function(color) {
		vertex_delete_buffer(mesh);
		buildMesh(color);
	}
	
	fireEvent = function(_event) {		
		switch(_event.type) {
			case "Create":
				tex    = sprite_get_texture(_event.params.sprite, _event.params.subimage);
				width  = sprite_get_width(_event.params.sprite);
				height = sprite_get_height(_event.params.sprite);
				buildMesh(c_white);
				break;
			
			case "Render":
				if(variable_struct_exists(_event.params, "flash")) {
					var flash = variable_struct_get(_event.params, "flash");
					if(flash mod 6) > 1 {
						_event.params.flash = 0;
						_event.params.color = c_white;
						break;
					}
				}
				
				if(_event.params.color != color) {
					color = _event.params.color;
					rebuildMesh(color);
				}
				
				var zRot = Camera.lookDir + Camera.lookDirOffset + 90;
				matrix_set(matrix_world, matrix_build(_event.params.x, _event.params.y, _event.params.z, 0, 0, zRot, 1, 1, 1));
				vertex_submit(mesh, pr_trianglelist, sprite_get_texture(_event.params.sprite, _event.params.subimage));
				shader_reset();
				
				_event.params.color = c_white;
				break;
		}
		return _event;
	}
}
function BillboardSpriteComponent(c_Name) : Component(c_Name) constructor {
	other.listen("Render");
	
	fireEvent = function(_event) {		
		switch(_event.type) {
			case "Render":
				if(variable_struct_exists(_event.params, "flash")) {
					var flash = variable_struct_get(_event.params, "flash");
					if(flash mod 6) > 1 {
						break;
					}
					
				}
				draw_sprite_billboard(_event.params.sprite, _event.params.subimage, _event.params.x, _event.params.y, _event.params.z, _event.params.color)
				break;
		}
		return _event;
	}
}
function DefaultShaderComponent(c_Name) : Component(c_Name) constructor {
	fireEvent = function(_event) {		
		switch(_event.type) {
			case "Render":
				shader_set(shDefault);
				break;
		}
		
		return _event;
	}
}
function DeathParticleComponent(c_Name) : Component(c_Name) constructor {
	sprite = sHit;
	width  = TileDim / 2;
	height = TileDim / 2;
	
	fireEvent = function(_event) {		
		switch(_event.type) {
			case "Destroy":
				var pObject = getParent();
				var xx = pObject.get("Position", "x") + (pObject.get("Transform", "x") ?? 0);
				var yy = pObject.get("Position", "y") + (pObject.get("Transform", "y") ?? 0);
				var zz = pObject.get("Position", "z") + (pObject.get("Transform", "z") ?? 0);
				
				var particle = instance_create_layer(xx, yy, "Instances", Billboard, {
					sprite_index: sprite,
					width:        width,
					height:       height
				})
				particle.buildMesh();
				break;
		}
		
		return _event;
	}
}
function DebugDjikstraComponent(c_Name) : Component(c_Name) constructor {
	fireEvent = function(_event) {		
		switch(_event.type) {
			case "Render":
				//Debug Djikstra
				var xx = floor(_event.params.x / TileDim);
				var yy = floor(_event.params.y / TileDim);
				var dist = Camera.djikstra[xx][yy]
				matrix_set(matrix_world, matrix_build(_event.params.x, _event.params.y, _event.params.z + 3, 90, 90, Camera.lookDir, 1, 1, 1));
	
				draw_set_colour(c_white)
	
				draw_set_halign(fa_center);
				draw_set_valign(fa_bottom);
				draw_text(0, 0, dist)
				draw_set_halign(fa_left);
				draw_set_valign(fa_top);
				matrix_set(matrix_world, matrix_build_identity());
				break;
		}
		
		return _event;
	}
}
function FireElementComponent(c_Name) : Component(c_Name) constructor {
	hitDice = "1d6";
	fireEvent = function(_event) {
		switch(_event.type) {
			case "DealMeleeDamage":
				_event.params.amount += roll(hitDice);
				_event.params.type += ",fire";
				break;
		}
		return _event;
	}
}
function HealthComponent(c_Name) : Component(c_Name) constructor {
	hp         = 10;
	maxHp      = 10;
	
	deathTimer = 12;
	
	fireEvent = function(_event) {		
		switch(_event.type) {			
			case "TakeDamage":
				hp = max(0, hp - _event.params.amount);
				show_debug_message($"Took {_event.params.amount} damage");
				
				//This is temporary but look!
				if(hp == 0) addTimesource("IDied", World, deathTimer, function(){destroyEntity(World.entities[? parent])});
				break;
		}
		return _event;
	}
}
function ImpassableComponent(c_Name) : Component(c_Name) constructor {
	bumping = true;
	
	fireEvent = function(_event) {		
		switch(_event.type) {			
			default:
				break;
		}
		return _event;
	}
}
function ShakeScreenComponent(c_Name) : Component(c_Name) constructor {
	screenShake          = 6;
	screenShakeIntensity = 1;
	
	fireEvent = function(_event) {		
		switch(_event.type) {			
			case "TakeDamage":
				Camera.screenShake          = screenShake;
				Camera.screenShakeIntensity = screenShakeIntensity;
				break;
		}
		return _event;
	}
}
function HurtColorComponent(c_Name) : Component(c_Name) constructor {
	hurtTimer = 12;
	
	fireEvent = function(_event) {		
		switch(_event.type) {			
			case "Render":
				var col = #ffffff;
				if (_event.params.flash > hurtTimer * .25) col = #ff00ff;
				if (_event.params.flash > hurtTimer * .33) col = #aa00ff;
				if (_event.params.flash > hurtTimer * .41) col = #0000ff;
				if (_event.params.flash > hurtTimer * .50) col = #00ff00;
				if (_event.params.flash > hurtTimer * .66) col = #ffff00;
				if (_event.params.flash > hurtTimer * .82) col = #ffaa00;
				if (_event.params.flash > hurtTimer * .75) col = #ff0000;
				_event.params.color = col;
				break;
		}
		return _event;
	}
}
function HurtSpriteComponent(c_Name) : Component(c_Name) constructor {
	sprite    = sBBGrass_Stepped;
	hurt      = false;
	hurtTimer = 12;
	
	unhurt = function() {
		self.hurt = false;
	}
	
	fireEvent = function(_event) {		
		switch(_event.type) {			
			case "TakeDamage":
				hurt = true;
				addTimesource($"{componentName}isHurting", World, hurtTimer, unhurt);
				break;
			case "Render":
				if hurt _event.params.sprite = self.sprite;
				break;
		}
		return _event;
	}
}
function HurtSubimageComponent(c_Name) : Component(c_Name) constructor {
	subimage  = 0;
	hurt      = false;
	hurtTimer = 12;
	
	unhurt = function() {
		self.hurt = false;
	}
	
	fireEvent = function(_event) {		
		switch(_event.type) {			
			case "TakeDamage":
				hurt = true;
				addTimesource($"{componentName}isHurting", World, hurtTimer, unhurt);
				break;
			case "Render":
				if hurt _event.params.subimage = self.subimage;
				break;
		}
		return _event;
	}
}
function InvulnComponent(c_Name) : Component(c_Name) constructor {
	fireEvent = function(_event) {
		switch(_event.type) {
			case "TakeDamage":
				_event.params.amount = 0;
				break;
		}
		return _event;
	}
}
function LootComponent(c_Name) : Component(c_Name) constructor {
	items = [];
	fireEvent = function(_event) {
		switch(_event.type) {
			case "Destroy":
				_event.params.items = self.items;
				break;
		}
		return _event;
	}
}
function PhysicsComponent(c_Name) : Component(c_Name) constructor {	
	flash      = 0;
	color      = c_white;
	maxFlash   = 12;
	
	fireEvent = function(_event) {		
		switch(_event.type) {
			case "TakeDamage":
				flash = maxFlash;
				break;
			case "Render":
				flash = max(0, flash - 1);
				
				_event.params.color = color;
				_event.params.flash = flash;
				break;
			default:
				//show_debug_message($"Event Data Type: {_event.type}, Params: {_event.params}");
				break;
		}		
		return _event;
	}
}
function PositionComponent(c_Name) : Component(c_Name) constructor {
	x = undefined; y = undefined; z = undefined;
	
	fireEvent = function(_event) {		
		switch(_event.type) {
			case "Move":
				self.x += _event.params.x;
				self.y += _event.params.y;
				self.z += _event.params.z;
				break;
			case "Place":
				self.x = _event.params.x;
				self.y = _event.params.y;
				self.z = _event.params.z;
				break;
			case "Render":
				_event.params.x = self.x;
				_event.params.y = self.y;
				_event.params.z = self.z;
				break;
			case "Step":
				variable_struct_set(_event.params, "steppedOn", false)
				if(_event.params.x == self.x and _event.params.y == self.y and _event.params.z == self.z)  variable_struct_set(_event.params, "steppedOn", true);
				break;
		}
		
		return _event;
	}
}
function SpriteComponent(c_Name) : Component(c_Name) constructor {
	sprite    =  sBBGrass;
	subimage  =         0;
	randomSubimage = false;
	
	setRandomSubImage = function() {
		subimage = irandom(sprite_get_number(sprite) - 1);
	}
	
	fireEvent = function(_event) {		
		switch(_event.type) {
			case "Create":
				_event.params.sprite   = self.sprite;
				_event.params.subimage = self.subimage;
				if randomSubimage setRandomSubImage();
				break;
			
			case "Render":
				_event.params.sprite   = self.sprite;
				_event.params.subimage = self.subimage;
				break;
		}
		
		return _event;
	}
}
function SteppedOnComponent(c_Name) : Component(c_Name) constructor {
	sprite = sBBGrass_Stepped;
	steppedOn = false;
	
	other.listen("Step");
				
	fireEvent = function(_event) {		
		switch(_event.type) {
			case "Render":
				if !steppedOn break;
				_event.params.sprite = self.sprite;
				break;
			case "Step":
				steppedOn = _event.params.steppedOn;
				break;
		}
		
		return _event;
	}
}
function TransformComponent(c_Name) : Component(c_Name) constructor {
	x = 0;
	y = 0;
	z = 0;
	
	xScale = 1;
	yScale = 1;
	zScale = 1;
		
	fireEvent = function(_event) {		
		switch(_event.type) {
			case "Render":
				_event.params.x += self.x;
				_event.params.y += self.y;
				_event.params.z += self.z;
				_event.params.xScale = xScale;
				_event.params.yScale = yScale;
				_event.params.zScale = zScale;
				break;
		}
		
		return _event;
	}
}
function WeaponComponent(c_Name) : Component(c_Name) constructor {
	hitDice = "1d6";
	damageType = "slashing";
	fireEvent = function(_event) {
		switch(_event.type) {
			case "DealMeleeDamage":
				_event.params.amount = roll(hitDice);
				_event.params.type = damageType;
				break;
		}
		return _event;
	}
}
function WindShaderComponent(c_Name) : Component(c_Name) constructor {
	sway = 500;
	
	fireEvent = function(_event) {		
		switch(_event.type) {
			case "Render":
				shader_set(shWind);	
				shader_set_uniform_f(shader_get_uniform(shWind, "windSpeed"), current_time/self.sway);
				shader_set_uniform_f(shader_get_uniform(shWind, "baseZ"), _event.params.z);
				break;
		}
		
		return _event;
	}
}
function WorldTileComponent(c_Name) : Component(c_Name) constructor {
	gridX         =              0;
	gridY         =              0;
	worldMeshes   =             [];
	isBlocking    =          false;
	destroyedTile = TileTypes.NULL;
	
	fireEvent = function(_event) {		
		switch(_event.type) {
			case "Destroy":
				World.tiles[gridX][gridY].tile   = destroyedTile;
				if !array_length(worldMeshes) == 0 World.buildMesh(worldMeshes, floor(gridX/5), floor(gridY/5));
				if isBlocking tilemap_set(World.coll, 0, gridX, gridY);
				break;
		}
		
		return _event;
	}
}
