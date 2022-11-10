extends CanvasLayer

enum{
	WEAPON,
	FOOD
}

var selected_item = 0
var selected_chest = 0
var selected_item_type = 0
var chest_inventory_button_res = preload("res://game/ui/assets/chest_inventory_button.tscn")

func _ready():
	for x in get_children():
		x.visible = false

func _process(_delta):
	match selected_item_type:
		WEAPON:
			$NinePatchRect/VBoxContainer/HBoxContainer/Panel/Label.text = global.weapon_name_list[selected_item] + "\n" + global.weapon_desc_list[selected_item]
		FOOD:
			$NinePatchRect/VBoxContainer/HBoxContainer/Panel/Label.text = global.food_name_list[selected_item] + "\n" + global.food_desc_list[selected_item]

func open_chest(id):
	selected_chest = id
	if global.chest_data[selected_chest][0] != []:
		selected_item = global.chest_data[selected_chest][0][0]
		selected_item_type = WEAPON
	else:
		selected_item = global.chest_data[selected_chest][1][0]
		selected_item_type = FOOD
	for x in get_children():
		x.visible = true
	get_tree().paused = true
	for x in $NinePatchRect/VBoxContainer/HBoxContainer/Panel2/ScrollContainer/VBoxContainer.get_children():
		x.queue_free()
	for x in global.chest_data[id][0]:
		var chest_inventory_button = chest_inventory_button_res.instance()
		$NinePatchRect/VBoxContainer/HBoxContainer/Panel2/ScrollContainer/VBoxContainer.add_child(chest_inventory_button)
		chest_inventory_button.id = x
		chest_inventory_button.type = WEAPON
	print(global.chest_data)
	for x in global.chest_data[id][1]:
		var chest_inventory_button = chest_inventory_button_res.instance()
		print(x)
		$NinePatchRect/VBoxContainer/HBoxContainer/Panel2/ScrollContainer/VBoxContainer.add_child(chest_inventory_button)
		chest_inventory_button.id = x
		chest_inventory_button.type = FOOD


func exit():
	for x in get_children():
		x.visible = false
		get_tree().paused = false

func _on_get_items_pressed():
	for x in global.chest_data[selected_chest][0]:
		global.give_weapon(x)
	for x in global.chest_data[selected_chest][1]:
		global.give_food(x)
	global.chest_data[selected_chest] = []
	exit()
