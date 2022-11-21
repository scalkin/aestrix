extends Area2D

func _on_not_yet_area_entered(_area):
	if $Timer.time_left == 0:
		dialogue.start("not_yet")
