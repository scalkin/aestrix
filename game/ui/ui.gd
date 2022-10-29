extends CanvasLayer

var prev_frame_tab
var inventory_button_res = preload("res://game/ui/assets/inventory_button.tscn")

func _ready():
	$TabContainer.visible = false

func _physics_process(_delta):
	$TabContainer/Player/HBoxContainer/Panel/VBoxContainer/player_stats.text = "Level " + str(global.level) + "\nStrength: " + str(global.player_stats[0]) + "\nAgility: " + str(global.player_stats[1]) + "\nDefense: " + str(global.player_stats[2]) + "\nXP: " + str(global.xp) + "/" + str(global.level_xp_list[global.level])
	$TabContainer/Player/HBoxContainer/ability_points/ability_points/Label.text = "Attribute points: " + str(global.attribute_points)
	for x in get_children():
		x.visible = $TabContainer.visible
	get_tree().paused = $TabContainer.visible
	if Input.is_action_just_pressed("menu"):
		$TabContainer.visible = not $TabContainer.visible
	$TabContainer/Inventory/HBoxContainer/Panel2/Label.text = global.item_name_list[global.held_item_id] + "\n" + global.item_desc_list[global.held_item_id]

func _on_Button_pressed():
	print("Exited with code 0")
	get_tree().quit(0)


func inventory_tab():
	print("clicked")
	for x in $TabContainer/Inventory/HBoxContainer/Panel/ScrollContainer/VBoxContainer.get_children():
		x.queue_free()
	print(global.parse_inventory())
	for x in global.parse_inventory():
		var inventory_button = inventory_button_res.instance()
		$TabContainer/Inventory/HBoxContainer/Panel/ScrollContainer/VBoxContainer.add_child(inventory_button)
		inventory_button.id = x

func _on_TabContainer_tab_changed(tab):
	match tab:
		0:
			pass
		1:
			inventory_tab()
		2:
			pass
