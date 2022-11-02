extends Node2D

enum{
	MOUSE
	CONTROLLER
}

var player_accel = 500
var player_max_speed = 200
export var held_item_id = 1
var inventory = [0, 1, 0, 0, 0]
var item_desc_list = [
	"Not a lightsaber.\n\n5 Damage\n140 degree swing\n14 pixel blade",
	"A simple weapon, designed to be easily concealed.\n\n1 Damage\n120 degree swing\n6 pixel blade",
	"The larger blade on this dagger barely affects anything.\n\n1 Damage\n130 degree swing\n8 pixel blade",
	"A slim, two-edged sword, with greater damage than a dagger.\n\n2 Damage\n120 degree swing\n13 pixel blade",
	"A heavy battleaxe such as this allows for great damage, at the cost of speed.\n\n3 Damage\n170degree swing\n12 pixel blade"
]
var item_name_list = [
	"Energy Sword",
	"Small Dagger",
	"Medium Dagger",
	"Rapier",
	"Battleaxe"
]
var item_sprite_list = [
	load("res://game/items/weapons/energy_sword_1.png"),
	load("res://game/items/weapons/dagger_1.png"),
	load("res://game/items/weapons/dagger_2.png"),
	load("res://game/items/weapons/rapier_1.png"),
	load("res://game/items/weapons/battleaxe.png"),
]

var player_stats = [
	0,#strength
	0,#agility
	0#defense
]

var chest_data = [
	[0],
	[2, 3],
]

var level_xp_list = [0, 50, 100]
var level_attribute_points = [0, 1, 0]
var xp = 0
var xp_to_next_level = 0
var level = 1
var target_mode = MOUSE
var last_mouse_pos = Vector2.ZERO
var attribute_points = 0

func save():
	var save_dict = {
		"xp" : xp,
		"level" : level,
		"attribute_points" : attribute_points,
		"chest_data" : chest_data,
		"player_stats" : player_stats,
		"inventory" : inventory,
		"held_item_id" : held_item_id,
		"player_max_speed" : player_max_speed,
		"player_accel" : player_accel,
		"fullscreen" : OS.window_fullscreen
	}
	print(save_dict)
	return save_dict

func reset():
	var save_dict = {
		"xp" : 0,
		"level" : 1,
		"attribute_points" : 0,
		"chest_data" : [[0],[2, 3],],
		"player_stats" : [0, 0, 0],
		"inventory" : [0, 1, 0, 0, 0],
		"held_item_id" : 1,
		"player_max_speed" : 200,
		"player_accel" : 500,
	}
	save_game(save_dict)

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
		for i in node_data.keys():
			if not i in ["fullscreen"]:
				set(i, node_data[i])
			else:
				match i:
					"fullscreen":
						OS.window_fullscreen = node_data[i]
	save_game.close()

func _ready():
	randomize()
	print(get_tree().current_scene.filename)
	load_game()

func _process(_delta):
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
	var result = []
	var index = 0
	for x in inventory:
		if inventory[index] != 0:
			for _y in range(0, inventory[index]):
				result.append(index)
		index += 1
	return(result)

func give_item(item_id):
	inventory[item_id] = inventory[item_id] + 1
	print("recieved item with id " + str(item_id))
	print(inventory)
