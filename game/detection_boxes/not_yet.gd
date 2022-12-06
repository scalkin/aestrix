extends Area2D

export var dialogue_id = "not_yet"

func _on_not_yet_area_entered(_area):
	if $Timer.time_left == 0:
		dialogue.start(dialogue_id)
