extends Button

enum{
	WEAPONS,
	FOOD
}

var id = 0
var type = 0

func _process(_delta):
	match type:
		WEAPONS:
			text = global.weapon_name_list[id]
			icon = global.weapon_sprite_list[id]
		FOOD:
			text = global.food_name_list[id]
			icon = global.food_sprite_list[id]

func _on_Button_pressed():
	chest_ui.selected_item = id
	chest_ui.selected_item_type = type
