extends Node2D

enum{
	MOUSE
	CONTROLLER
}
enum{
	MONK,
	ROGUE,
	MOVEMENT
}
onready var transition_effect = $CanvasLayer2/ColorRect
export var health = 10.0 setget set_health
export var max_health = 10.0
var start_location = Vector2.ZERO #used for travelling between scenes
var player_accel = 500
var player_max_speed = 100
var player_max_run_speed = 150
export var held_item_id = 1
var loaded = false #is false while loading
var loaded2 = false #is false until loaded at least once
var vignette = true
var weapon_swing_size_list = [140, 120, 130, 120, 170, 170, 130]
var weapon_blade_length_list = [14, 6, 8, 13, 12, 20, 8]
var weapon_damage_list = [5, 2, 0, 2, 3, 3, 3]
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
#Just like the weapons inventory
var food_inventory = [
				5,#Bread
				1,#Baked potato
]
#This one should be obvious
var weapon_desc_list = [
	"A more civilized weapon.\n\n" + \
	str(weapon_damage_list[0]) + " Damage\n" + \
	str(weapon_blade_length_list[0]) + " degree swing\n" + str(weapon_swing_size_list[0]) + " pixel blade",
	"A simple weapon, designed to be easily concealed.\n\n" + \
	str(weapon_damage_list[1]) + " Damage\n" + \
	str(weapon_blade_length_list[1]) + " degree swing\n" + \
	str(weapon_swing_size_list[1]) + " pixel blade",
	"The larger blade on this dagger barely affects anything.\n\n" + \
	str(weapon_damage_list[2]) + " Damage\n" + \
	str(weapon_blade_length_list[2]) + " degree swing\n" + \
	str(weapon_swing_size_list[2]) + " pixel blade",
	"A slim, two-edged sword, with greater damage than a dagger.\n\n" + str(weapon_damage_list[3]) + " Damage\n" + \
	str(weapon_blade_length_list[3]) + " degree swing\n" + \
	str(weapon_swing_size_list[3]) + " pixel blade",
	"A heavy battleaxe such as this allows for great damage, at the cost of speed.\n\n" + \
	str(weapon_damage_list[4]) + " Damage\n" + \
	str(weapon_blade_length_list[4]) + " degree swing\n" + \
	str(weapon_swing_size_list[4]) + " pixel blade",
	"It's long and a sword.\n\n" + \
	str(weapon_damage_list[5]) + " Damage\n" + \
	str(weapon_blade_length_list[5]) + " degree swing\n" + \
	str(weapon_swing_size_list[5]) + " pixel blade",
	"Infused with lunar magic, this dagger is capable of a higher damage output and speed.\n\n" + \
	str(weapon_damage_list[6]) + " Damage\n" + \
	str(weapon_blade_length_list[6]) + " degree swing\n" + \
	str(weapon_swing_size_list[6]) + " pixel blade"
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
#list of sprites for different weapons
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
#how much health the item heals
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
#its a list of lists. for example, chest_data[0] would return [[], [0, 0, 0]], and the first list would be the weapons, and the second is the food
var chest_data = [
	[[], [0, 0, 0]],
	[[6], [1]],
]
var quests = {
	"completed_quests" : [],
	"completed_objectives" : [[], []],
	"quests_recieved" : []
} setget update_quests
#just some data about the quests that doesn't change
var quest_data = {
	"names" : ["Once upon a time...", "To new lands!"],
	"objective_decriptions" : [["Ozin has requested that you deal with the rats in his basement. If you complete the task, you can keep the magical dagger in the basement.", "You've killed half the rats in the basement so far. Remember that if you are low on health, you can eat food by switching to the backpack tab and clicking the 'food' button, selecting some food, and hitting 'equip/use'.", "You've killed all the rats in the basement, you should grab the dagger from that chest now.", "You've cleared the basement, now go tell Ozin about your success.", "Quest completed"], ["Wilfred has advised that you travel to Axehithe, south through the forest.", "On your way to Axehithe, you were kidnapped by a group of dark wizards. They seem to have brought you to some kind of cave, you should probably get out of here, you don't know what they are trying to do.", "After killing a few more of these bats, the path out will be clear.", "After killing those bats, the path out seems to be clear"]],
	"objectives_in_quest" : [4, 3],
}

var xp = 0 setget set_xp
var level = 1
#used to determine if the player is using a mouse or controller
var target_mode = MOUSE
#also used for mouse/controller detection
var last_mouse_pos = Vector2.ZERO
#how many points we have to spend on upgrades
var attribute_points = 0
#player's global_position; updated on save
var player_position = Vector2(135, -67) setget set_player_position
var current_scene
var player_direction

signal game_loaded
signal game_saved
#used to notify player script that the player_position variable has been updated and to update global_position accordingly
signal player_position_updated

func max_run_speed():
	return 150 + 10*player_stats[4]

func set_player_position(value : Vector2):
	print("set player position to " + str(value))
	player_position = value
	emit_signal("player_position_updated")
#returns the maximum level upgrades available at current level
func max_upgrade_level(cur_level):
	if cur_level > 20:
		return 5
	if cur_level > 15:
		return 4
	if cur_level > 10:
		return 3
	if cur_level > 5:
		return 2
	else:
		return 1
	
#compares recieved and completed quests to determine what quests the player currently has
func current_quests():
	var result = []
	for x in global.quests["quests_recieved"]:
		if not x in global.quests["completed_quests"]:
			result.append(x)
	return result
#ierates over the list of completed objectives for a particular quest id to find the highest one
func quest_objective(id):
	var result = 0
	for x in quests["completed_objectives"][id]:
		if x > result:
			result = x
	return result

func update_quests(value):
	quests = value
	var index = 0
	var parsed_ids = []
	for x in quests["completed_quests"]:
		x = float(x)
		if x in parsed_ids:
			quests["completed_quests"].pop_at(index)
		parsed_ids.append(x)
		index += 1
	index = 0
	for x in quests["quests_recieved"]:
		x = float(x)
		if x in parsed_ids:
			quests["quests_recieved"].pop_at(index)
		parsed_ids.append(x)
		index += 1
	for x in quests["completed_objectives"]:
		parsed_ids = []
		index = 0
		for y in x:
			if y in parsed_ids:
				x.pop_at(index)
			y = int(y)
			parsed_ids.append(y)
			index += 1
	index = 0
	for x in quests["completed_objectives"]:
		if not index in quests["completed_quests"]:
			for y in x:
				if y == quest_data["objectives_in_quest"][index]:
					quests["completed_quests"].append(index)
		index += 1

func set_player_stats(value):
	player_stats = value

func set_xp(value):
	xp = value
	if xp >= xp_to_next_level(level):
		while xp >= xp_to_next_level(level):
			xp -= xp_to_next_level(level)
			level += 1
			max_health += 1
			health += 1
			if not level < 3:
				attribute_points += 1

func xp_to_next_level(cur_level:float):
	return 15*round(((cur_level*cur_level)/(sqrt(cur_level))))

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
	loaded2 = false
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
			if not i in ["fullscreen", "player_position_x", "player_position_y", "quests"]:
				set(i, node_data[i])
			else:
				match i:
					"fullscreen":
						OS.window_fullscreen = node_data[i]
					"player_position_x":
						self.player_position.x = int(node_data[i])
					"player_position_y":
						self.player_position.y = int(node_data[i])
					"quests":
						self.quests = node_data[i]
						var index_x = 0
						for x in quests["completed_objectives"]:
							var index = 0 
							for y in x:
								quests["completed_objectives"][index_x][index] = int(y)
								index += 1
							index_x += 1
						index_x = 0
						for x in quests["completed_quests"]:
							quests["completed_quests"][index_x] = int(x)
							index_x += 1
						for x in quests["quests_recieved"]:
							var index = 0 
							quests["quests_recieved"][index] = int(index)
							index_x += 1
	Dialogic.load()
	loaded = true
	loaded2 = true
	save_game.close()
	print("Player position passed to travel scene function: " + str(player_position))
	travel_scene(current_scene, player_position, false)
	emit_signal("game_loaded")
	return true

func _ready():
	$AnimationPlayer.play("open")
	randomize()
	print(get_tree().current_scene.filename)
	if not load_game():
		save_game(reset())

func _process(delta):
	$CanvasLayer/TextureRect.visible = vignette
	OS.window_size.x = clamp(OS.window_size.x, OS.window_size.y, OS.window_size.y*2)
	if (not get_tree().paused) and health < max_health:
		health += (delta*0.25)*(max_health/10)
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
	print(loaded2)
	if not loaded2:
# warning-ignore:return_value_discarded
		get_tree().change_scene(scene)
		return
	current_scene = scene
	get_tree().paused = true
	$AnimationPlayer.play("close")
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


func transition_closed():
# warning-ignore:return_value_discarded
	get_tree().change_scene(current_scene)
	$AnimationPlayer.play("open")
	get_tree().paused = false
