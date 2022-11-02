extends CanvasLayer

var selected_item = 0
var selected_chest = 0
var chest_inventory_button_res = preload("res://game/ui/assets/chest_inventory_button.tscn")

func _ready():
	selected_item = global.chest_data[selected_chest][selected_item]
	for x in get_children():
		x.visible = false

func _process(_delta):
	$NinePatchRect/VBoxContainer/HBoxContainer/Panel/Label.text = global.item_desc_list[selected_item]

func open_chest(id):
	selected_chest = id
	for x in get_children():
		x.visible = true
	get_tree().paused = true
	for x in $NinePatchRect/VBoxContainer/HBoxContainer/Panel2/ScrollContainer/VBoxContainer.get_children():
		x.queue_free()
	for x in global.chest_data[id]:
		var chest_inventory_button = chest_inventory_button_res.instance()
		$NinePatchRect/VBoxContainer/HBoxContainer/Panel2/ScrollContainer/VBoxContainer.add_child(chest_inventory_button)
		chest_inventory_button.id = x


func exit():
	for x in get_children():
		x.visible = false
		get_tree().paused = false

func _on_get_items_pressed():
	for x in global.chest_data[selected_chest]:
		global.give_item(x)
	global.chest_data[selected_chest] = []
	exit()
