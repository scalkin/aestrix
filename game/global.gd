extends Node2D

enum{
	MOUSE
	CONTROLLER
}

export var health = 10.0 setget set_health
export var max_health = 10.0
var start_location = Vector2.ZERO #used for travelling between scenes
var player_accel = 500
var player_max_speed = 200
export var held_item_id = 1
#Number represents how many are in inventory
var weapons_inventory = [
				0,#Energy sword(unused)
				1,#Small dagger
				0,#Medium Dagger
				0,#Rapier
				0,#Battleaxe
				0,#Longsword
]
var food_inventory = [
				5,#Bread
				1,#Baked potato
]
var weapon_desc_list = [
	"A more civilized weapon.\n\n5 Damage\n140 degree swing\n14 pixel blade",
	"A simple weapon, designed to be easily concealed.\n\n1 Damage\n120 degree swing\n6 pixel blade",
	"The larger blade on this dagger barely affects anything.\n\n1 Damage\n130 degree swing\n8 pixel blade",
	"A slim, two-edged sword, with greater damage than a dagger.\n\n2 Damage\n120 degree swing\n13 pixel blade",
	"A heavy battleaxe such as this allows for great damage, at the cost of speed.\n\n3 Damage\n170degree swing\n12 pixel blade",
	"It's long and a sword.\n\n3 Damage \n170 degree swing\n28 pixel blade"
]
var weapon_name_list = [
	"Energy Sword",
	"Small Dagger",
	"Medium Dagger",
	"Rapier",
	"Battleaxe",
	"Longsword"
]
var weapon_sprite_list = [
	load("res://game/items/weapons/energy_sword_1.png"),
	load("res://game/items/weapons/dagger_1.png"),
	load("res://game/items/weapons/dagger_2.png"),
	load("res://game/items/weapons/rapier_1.png"),
	load("res://game/items/weapons/battleaxe.png"),
	load("res://game/items/weapons/longsword.png")
]
var food_desc_list = [
	"It's bread.\n\nHeals 5",
	"\"Did you know they don't have baked potatoes in Ireland? Over there they just have baked potato.\"\n\nHeals 10"
]
var food_name_list = [
	"Bread",
	"Baked potato",
	"error"
]
var food_stats = [5, 10]
var food_sprite_list = [
	load("res://game/items/food/bread.png"),
	load("res://game/items/food/baked_potato.png"),
	load("res://icon.png")
]
var player_stats = [
	0,#strength
	0,#agility
	0#defense
]

var chest_data = [
	[[0, 5], [0]],
	[[2, 3], [1]],
]

var level_xp_list = [0, 50, 100]
var level_attribute_points = [0, 1, 0]
var xp = 0
var xp_to_next_level = 0
var level = 1
var target_mode = MOUSE
var last_mouse_pos = Vector2.ZERO
var attribute_points = 0
var player_position = Vector2.ZERO

signal game_loaded

func save():
	var save_dict = {
		"xp" : xp,
		"level" : level,
		"attribute_points" : attribute_points,
		"chest_data" : chest_data,
		"player_stats" : player_stats,
		"weapons_inventory" : weapons_inventory,
		"held_item_id" : held_item_id,
		"player_max_speed" : player_max_speed,
		"player_accel" : player_accel,
		"fullscreen" : OS.window_fullscreen,
		"max_health" : max_health,
		"health" : health,
		"current_scene" : get_tree().current_scene.filename,
		"player_position" : player_position,
	}
	print(save_dict)
	return save_dict

func reset():
	var save_dict = {
		"xp" : 0,
		"level" : 1,
		"attribute_points" : 0,
		"chest_data" : [[[0, 5], [0]], [[2, 3], [1]]],
		"player_stats" : [0, 0, 0],
		"inventory" : [0, 1, 0, 0, 0],
		"held_item_id" : 1,
		"player_max_speed" : 200,
		"player_accel" : 500,
		"current_scene" : "res://levels/hub.tscn"
	}
	save_game(save_dict)
	load_game()
	get_tree().reload_current_scene()

func save_game(data):
	var save_game = File.new()
	save_game.open("user://savegame.save", File.WRITE)
	save_game.store_line(to_json(data))
	save_game.close()

func load_game():
	var save_game = File.new()
	if not save_game.file_exists("user://savegame.save"):
		return
	save_game.open("user://savegame.save", File.READ)
	while save_game.get_position() < save_game.get_len():
		var node_data = parse_json(save_game.get_line())
		if node_data == null:
			return
		for i in node_data.keys():
			if not i in ["fullscreen", "current_scene"]:
				set(i, node_data[i])
			else:
				match i:
					"fullscreen":
						OS.window_fullscreen = node_data[i]
					"current_scene":
						travel_scene(i, player_position)
	emit_signal("game_loaded")
	save_game.close()

func _ready():
	randomize()
	print(get_tree().current_scene.filename)
	load_game()

func _process(delta):
	OS.window_size.x = clamp(OS.window_size.x, OS.window_size.y, OS.window_size.y*2)
	if (not get_tree().paused) and health < max_health:
		health += delta*0.25
		health = clamp(health, 0, 10)
	xp_to_next_level = level_xp_list[level]
	var controller_input_vector = Vector2.ZERO
	controller_input_vector.x = Input.get_axis("target_left", "target_right")
	controller_input_vector.y = Input.get_axis("target_up", "target_down")
	controller_input_vector = controller_input_vector.normalized()
	if Input.is_action_just_pressed("ui_focus_next") and OS.is_debug_build():
		match held_item_id:
			0:
				held_item_id = 1
			1:
				held_item_id = 2
			2:
				held_item_id = 3
			3:
				held_item_id = 4
			4:
				held_item_id = 5
			5:
				held_item_id = 0
	if controller_input_vector != Vector2.ZERO:
		target_mode = CONTROLLER
	elif get_local_mouse_position() != last_mouse_pos:
		last_mouse_pos = get_local_mouse_position()
		target_mode = MOUSE
	match target_mode:
		MOUSE:
			pass
		CONTROLLER:
			Input.warp_mouse_position((get_viewport().size/2)+(controller_input_vector*250))

func parse_inventory() -> Array:
	var weapons_result = []
	var food_result = []
	var index = 0
	for x in weapons_inventory:
		if weapons_inventory[index] != 0:
			weapons_result.append(index)
		index += 1
	index = 0
	for x in food_inventory:
		if food_inventory[index] != 0:
			food_result.append(index)
		index += 1
	return([weapons_result, food_result])

func give_weapon(id):
	weapons_inventory[id] = weapons_inventory[id] + 1
	print("recieved weapon with id " + str(id))
	print(weapons_inventory)

func give_food(id):
	food_inventory[id] = food_inventory[id] + 1
	print("recieved food with id " + str(id))
	print(food_inventory)

func travel_scene(scene: String, location: Vector2):
	start_location = location
# warning-ignore:return_value_discarded
	get_tree().change_scene(scene)

func set_health(value):
	health = value
	if health > max_health:
		health = max_health
	elif health <= 0:
		health = 0
		load_game()
		get_tree().reload_current_scene()
		global.travel_scene("res://levels/hub.tscn", Vector2.ZERO)
