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
var loaded = false
var numeral = [
	"",
	"I",
	"II",
	"III",
	"IV",
	"V",
	"VI",
	"VII",
	"VIII",
	"IX",
	"X",
	"XI",
	"XII",
	"XIII",
	"XIV",
	"XV",
	"XVI",
	"XVII",
	"XVIII",
	"XIX",
	"XX",
]
#Number represents how many are in inventory
var weapons_inventory = [
				0,#Energy sword(unused)
				1,#Small Dagger
				0,#Medium Dagger
				0,#Rapier
				0,#Battleaxe
				0,#Longsword
				0,#Lunar dagger
]
var food_inventory = [
				5,#Bread
				1,#Baked potato
]
var weapon_desc_list = [
	"A more civilized weapon.\n\n5 Damage\n140 degree swing\n14 pixel blade",
	"A simple weapon, designed to be easily concealed.\n\n1 Damage\n120 degree swing\n6 pixel blade",
	"The larger blade on this dagger barely affects anything.\n\n1 Damage\n130 degree swing\n8 pixel blade",
	"A slim, two-edged sword, with greater damage than a dagger.\n\n1 Damage\n120 degree swing\n13 pixel blade",
	"A heavy battleaxe such as this allows for great damage, at the cost of speed.\n\n3 Damage\n170 degree swing\n12 pixel blade",
	"It's long and a sword.\n\n3 Damage \n170 degree swing\n28 pixel blade",
	"Infused with lunar magic, this dagger is capable of a higher damage output and speed.\n\n2 Damage\n130 degree swing\n 8 pixel blade"
]
var weapon_name_list = [
	"Energy Sword",
	"Small Dagger",
	"Medium Dagger",
	"Rapier",
	"Battleaxe",
	"Longsword",
	"Lunar Dagger"
]
var weapon_sprite_list = [
	load("res://game/items/weapons/energy_sword_1.png"),
	load("res://game/items/weapons/dagger_1.png"),
	load("res://game/items/weapons/dagger_2.png"),
	load("res://game/items/weapons/rapier_1.png"),
	load("res://game/items/weapons/battleaxe.png"),
	load("res://game/items/weapons/longsword.png"),
	load("res://game/items/weapons/magic_dagger_1.png")
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
export var player_stats = [
	0,#strength
	0,#agility
	0,#defense
	0,#attack speed
	0,#walk speed
	0#knockback
] setget set_player_stats

var chest_data = [
	[[], [0, 0, 0]],
	[[6], [1]],
]
var quests = {
	"completed_quests" : [],
	"completed_objectives" : [[], []],
	"quests_recieved" : []
} setget update_quests

var quest_data = {
	"names" : ["Once upon a time..."],
	"objective_decriptions" : [["Ozin has requested that you deal with the rats in his basement. If you complete the task, you can keep the magical dagger in the basement.", "You've killed half the rats in the basement so far. Remember that if you are low on health, you can eat food by switching to the backpack tab and clicking the 'food' button, selecting some food, and hitting 'equip/use'.", "You've killed all the rats in the basement, you should grab the dagger from that chest now.", "You've cleared the basement, now go tell Ozin about your success.", "Quest completed."]],
	"objectives_in_quest" : [4],
}

var level_attribute_points = [0, 1, 0]
var xp = 0 setget set_xp
var level = 1
var target_mode = MOUSE
var last_mouse_pos = Vector2.ZERO
var attribute_points = 0
var player_position = Vector2(135, -67) setget set_player_position
var current_scene
var player_direction

signal game_loaded
signal game_saved
signal player_position_updated

func set_player_position(value : Vector2):
	print("set player position to " + str(value))
	player_position = value
	emit_signal("player_position_updated")

func max_upgrade_level(cur_level):
	if cur_level > 20:
		return 5
	return ceil(cur_level/5)+1

func current_quests():
	var result = []
	for x in global.quests["quests_recieved"]:
		if not x in global.quests["completed_quests"]:
			result.append(x)
	return result

func quest_objective(id):
	var result = 0
	for x in quests["completed_objectives"][id]:
		if x > result:
			result = x
	return result

func update_quests(value):
	if value["completed_objectives"] != quests["completed_objectives"]:
		var index = 0
		for x in value["completed_objectives"]:
			if not index in quests["completed_quests"]:
				for y in x:
					if y == quest_data["objectives_in_quest"][index]:
						value["completed_quests"].append(index)
			index += 1
	quests = value

func set_player_stats(value):
	player_stats = value
	player_max_speed = (player_stats[4]*50)+ 200

func set_xp(value):
	xp = value
	if xp >= xp_to_next_level(level):
		while xp >= xp_to_next_level(level):
			xp -= xp_to_next_level(level)
			level += 1
			max_health += 5
			health = max_health
			if not level < 3:
				attribute_points += 1

func xp_to_next_level(cur_level:float):
	return 15*round(((cur_level*cur_level)/(sqrt(cur_level))))

func health_at_level(cur_level:float):
	return 10*round(((cur_level*cur_level)/(sqrt(cur_level))))

func save():
	emit_signal("game_saved")
	var save_dict = {
		"xp" : xp,
		"level" : level,
		"attribute_points" : attribute_points,
		"chest_data" : chest_data,
		"player_stats" : player_stats,
		"weapons_inventory" : weapons_inventory,
		"food_inventory" : food_inventory,
		"held_item_id" : held_item_id,
		"player_max_speed" : player_max_speed,
		"player_accel" : player_accel,
		"fullscreen" : OS.window_fullscreen,
		"max_health" : max_health,
		"health" : health,
		"player_position_x" : player_position.x,
		"player_position_y" : player_position.y,
		"current_scene" : get_tree().current_scene.filename,
		"quests" : quests
	}
	return save_dict

func reset():
	var save_dict = {
		"current_quests" : [],
		"xp" : 0,
		"level" : 1,
		"attribute_points" : 0,
		"chest_data" : [[[], [0, 0, 0]],[[6], [1]]],
		"player_stats" : [0, 0, 0, 0, 0, 0],
		"weapons_inventory" : [0, 1, 0, 0, 0, 0, 0],
		"food_inventory" : [5, 1],
		"held_item_id" : 1,
		"player_max_speed" : 200,
		"player_accel" : 500,
		"max_health" : 10.0,
		"health" : 10.0,
		"player_position_x" : 135,
		"player_position_y" : -67,
		"current_scene" : "res://levels/hub.tscn",
		quests = {"completed_quests" : [],	"completed_objectives" : [[], []],	"quests_recieved" : []}
	}
	Dialogic.reset_saves()
	save_game(save_dict)
	load_game()
	print(parse_inventory())
	self.player_position = Vector2(135, -67)
	start_location = player_position


func save_game(data):
	print(data)
	var save_game = File.new()
	save_game.open("user://aestrix_save.json", File.WRITE)
	save_game.store_line(to_json(data))
	save_game.close()

func load_game():
	loaded = false
	var save_game = File.new()
	if not save_game.file_exists("user://aestrix_save.json"):
		return false
	save_game.open("user://aestrix_save.json", File.READ)
	while save_game.get_position() < save_game.get_len():
		var node_data = parse_json(save_game.get_line())
		if node_data == null:
			return false
		print(node_data.keys())
		for i in node_data.keys():
			if not i in ["fullscreen", "player_position_x", "player_position_y"]:
				set(i, node_data[i])
			else:
				match i:
					"fullscreen":
						OS.window_fullscreen = node_data[i]
					"player_position_x":
						self.player_position.x = int(node_data[i])
					"player_position_y":
						self.player_position.y = int(node_data[i])
	Dialogic.load()
	save_game.close()
	print("Player position passed to travel scene function: " + str(player_position))
	travel_scene(current_scene, player_position, false)
	emit_signal("game_loaded")
	return true

func _ready():
	randomize()
	print(get_tree().current_scene.filename)
	if not load_game():
		save_game(reset())

func _process(delta):
	OS.window_size.x = clamp(OS.window_size.x, OS.window_size.y, OS.window_size.y*2)
	if (not get_tree().paused) and health < max_health:
		health += delta*0.25
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

func travel_scene(scene: String, location: Vector2, save: bool):
	print(str(scene) + "\n" + str(location) + "\n")
	start_location = location
# warning-ignore:return_value_discarded
	get_tree().change_scene(scene)
	if save:
		var save_data = save()
		save_data["current_scene"] = scene
		save_data["player_position_x"] = location.x
		save_data["player_position_y"] = location.y
		call_deferred("save_game", save_data)

func set_health(value):
	health = value
	if health > max_health:
		health = max_health
	elif health <= 0:
		health = 0
		load_game()
# warning-ignore:return_value_discarded
		get_tree().reload_current_scene()
		travel_scene("res://levels/hub.tscn", Vector2.ZERO, false)
		global.save_game(global.save())
