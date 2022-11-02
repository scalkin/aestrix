extends StaticBody2D

export var chest_id = 0

func _process(_delta):
	if global.chest_data[chest_id] == []:
		queue_free()

func _on_Area2D_area_entered(_area):
	chest_ui.open_chest(chest_id)

func _on_Area2D_area_exited(_area):
	if global.chest_data[chest_id] == []:
		queue_free()
