globalvar EntityUUID;
EntityUUID = 0;

function Entity() constructor {
	uuid = ++EntityUUID;
	components    = [];
	subscriptions = [];
	
	addComponent = function(componentName, args = {}) {
		var component = constructComponent(componentName, args);
		component.parent = self;
		array_push( components, component );
		//ds_map_add(componentMap, componentName, component);
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
		var arrLen = array_length(components);
		for (var i = 0; i < arrLen; ++i) {
		    var component = components[i];
			_event = component.fireEvent(_event);
		}
		return _event;
	}
	
	destroy = function() {
		for (var i = 0; i < array_length(subscriptions); ++i) {
		    mute(subscriptions[i]);
		}
	}
	
}

function Component(c_Name) constructor {
	componentName = c_Name
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
function BillboardComponent(c_Name) : Component(c_Name) constructor {
	other.listen("Render");
	
	fireEvent = function(_event) {		
		switch(_event.type) {
			case"Create":
				
				mesh = vertex_create_buffer();
				tex  = sprite_get_texture(_event.params.sprite, _event.params.subimage);
				
				var width  = sprite_get_width(_event.params.sprite);
				var height = sprite_get_height(_event.params.sprite);
				
				vertex_begin(mesh, vFormat);
				addVertex(mesh, [-width/2, 0, height], [0, 1, 0], [0, 0], c_white, 1);
				addVertex(mesh, [ width/2, 0, height], [0, 1, 0], [1, 0], c_white, 1);
				addVertex(mesh, [ width/2, 0,      0], [0, 1, 0], [1, 1], c_white, 1);
				
				addVertex(mesh, [-width/2, 0, height], [0, 1, 0], [0, 0], c_white, 1);
				addVertex(mesh, [ width/2, 0,      0], [0, 1, 0], [1, 1], c_white, 1);
				addVertex(mesh, [-width/2, 0,      0], [0, 1, 0], [0, 1], c_white, 1);
				vertex_end(mesh);
				break;
			
			case "Render":
				var zRot = Camera.lookDir + Camera.lookDirOffset + 90;
				matrix_set(matrix_world, matrix_build(_event.params.x, _event.params.y, _event.params.z, 0, 0, zRot, 1, 1, 1));
				
				vertex_submit(mesh, pr_trianglelist, sprite_get_texture(_event.params.sprite, _event.params.subimage));
				shader_reset();
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
	hp        = 10;
	fireEvent = function(_event) {		
		switch(_event.type) {			
			case "TakeDamage":
				hp = max(0, hp - _event.params.amount);
				show_debug_message($"Took {_event.params.amount} damage");
				if(hp == 0) show_debug_message("OOOOoooow!");
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
function PhysicsComponent(c_Name) : Component(c_Name) constructor {
	fireEvent = function(_event) {		
		switch(_event.type) {		
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
			case "AtPosition":
				
				break;
			case "Move":
				self.x += _event.params.x;
				self.y += _event.params.y;
				self.z += _event.params.z;
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
