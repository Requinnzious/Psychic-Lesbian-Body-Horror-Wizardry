Config = init_config();

//A default entity with no components
entity = new Entity();

//We add components like this
entity.addComponent("PhysicsComponent");
entity.addComponent("PositionComponent", {x: 0, y: 16});
entity.addComponent("TransformComponent");
entity.addComponent("SpriteComponent", {sprite: S, frame: 0});
//We can pass in a struct of properties when adding a component
entity.addComponent("ArmorComponent",  {armorValue: 1});
entity.addComponent("WeaponComponent", {hitDice: "2d6"});
entity.addComponent("FireElementComponent", {hitDice: "2d6"});
//Components receive and mutate events in order
//Putting armor before health will give us Damage Reduction
entity.addComponent("HealthComponent");

//A test event with some parameters
event = new Event("DealMeleeDamage", {});
event = entity.fireEvent(event);

//Call an event on an entity, and the event will fire on all of its components in order
//We have 6 DV, so we'll take 4 damage
show_debug_message(event);
