extends Button

var id = 0

func _process(_delta):
	text = global.item_name_list[id]
	icon = global.item_sprite_list[id]

func _on_Button_pressed():
	chest_ui.selected_item = id
