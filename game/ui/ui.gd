extends CanvasLayer

enum{
	WEAPONS,
	FOOD
}

var prev_frame_tab
var inventory_button_res = preload("res://game/ui/assets/inventory_button.tscn")
var quest_button_res = preload("res://game/ui/assets/quest_button.tscn")
var selected_item = 0
var selected_item_type = WEAPONS
var selected_quest = 0

func _ready():
	$TabContainer/menu/HBoxContainer/Panel/settings/VBoxContainer/fullscreen.pressed = OS.window_fullscreen
	$TabContainer/menu/HBoxContainer/Panel/settings/VBoxContainer/volume.value = musicplayer.volume
	$TabContainer.visible = false

func _physics_process(_delta):
	$NinePatchRect/health_label.text = str(int(global.health)) + "/" + str(int(global.max_health))
	process_settings()
	$TabContainer/player/HBoxContainer/Panel/VBoxContainer/player_stats.text = "Level " + str(global.level) + "\nStrength: " + str(global.player_stats[0]) + "\nAgility: " + str(global.player_stats[1]) + "\nDefense: " + str(global.player_stats[2]) + "\nXP: " + str(global.xp) + "/" + str(global.xp_to_next_level(global.level))
	$TabContainer/player/HBoxContainer/ability_points/ability_points/Label.text = "Attribute points: " + str(global.attribute_points)
	$ColorRect.visible = $TabContainer.visible
	if Input.is_action_just_pressed("menu") and ($TabContainer.visible or not get_tree().paused):
		$TabContainer.visible = not $TabContainer.visible
		get_tree().paused = $TabContainer.visible
		load_inventory(WEAPONS)
		load_quests()
	match selected_item_type:
		WEAPONS:
			$TabContainer/backpack/VBoxContainer/HBoxContainer/Panel2/VBoxContainer/ScrollContainer/Label.text = global.weapon_name_list[selected_item] + "\n" + global.weapon_desc_list[selected_item] + "\n\n" + str(global.weapons_inventory[selected_item]) + " in inventory"
		FOOD:
			$TabContainer/backpack/VBoxContainer/HBoxContainer/Panel2/VBoxContainer/ScrollContainer/Label.text = global.food_name_list[selected_item] + "\n" + global.food_desc_list[selected_item] + "\n\n" + str(global.food_inventory[selected_item]) + " in inventory"
	if global.current_quests() != []:
		$TabContainer/quests/HBoxContainer/Panel/Label.text = global.quests["objective_decriptions"][selected_quest][global.quest_objective(selected_quest)]
	else:
		$TabContainer/quests/HBoxContainer/Panel/Label.text = "There are no quests here."
	$NinePatchRect/TextureRect.rect_size.x = int((global.health/global.max_health)*46)

func _on_Button_pressed():
	print("Exited with code 0")
	get_tree().quit(0)


func load_inventory(item_type):
	selected_item_type = item_type
	selected_item = global.parse_inventory()[item_type][0]
	for x in $TabContainer/backpack/VBoxContainer/HBoxContainer/Panel/ScrollContainer/VBoxContainer.get_children():
		x.queue_free()
	for x in global.parse_inventory()[item_type]:
		var inventory_button = inventory_button_res.instance()
		$TabContainer/backpack/VBoxContainer/HBoxContainer/Panel/ScrollContainer/VBoxContainer.add_child(inventory_button)
		inventory_button.id = x
		inventory_button.type = item_type

func load_quests():
	for x in $TabContainer/quests/HBoxContainer/Panel2/ScrollContainer/VBoxContainer.get_children():
		x.queue_free()
	if global.quests["quests_recieved"] != []:
		for x in global.quests["quests_recieved"]:
			if not x in global.quests["completed_quests"]:
				var quest_button = quest_button_res.instance()
				$TabContainer/quests/HBoxContainer/Panel2/ScrollContainer/VBoxContainer.add_child(quest_button)

func _on_save_pressed():
	get_tree().paused = false
	$TabContainer.visible = false
	global.save_game(global.save())

func _on_reset_pressed():
	get_tree().paused = false
	$TabContainer.visible = false
	global.save_game(global.reset())
	global.load_game()

func process_settings():
	OS.window_fullscreen = $TabContainer/menu/HBoxContainer/Panel/settings/VBoxContainer/fullscreen.pressed
	musicplayer.volume = $TabContainer/menu/HBoxContainer/Panel/settings/VBoxContainer/volume.value

func _on_use_button_pressed():
	match selected_item_type:
		WEAPONS:
			global.held_item_id = selected_item
		FOOD:
			if global.health >= global.max_health:
				return
			else:
				global.food_inventory[selected_item] -= 1
				global.health += global.food_stats[selected_item]
				load_inventory(FOOD)
func _on_weapon_button_pressed():
	load_inventory(WEAPONS)

func _on_food_button_pressed():
	load_inventory(FOOD)
