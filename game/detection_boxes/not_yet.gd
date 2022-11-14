extends Area2D

func _on_not_yet_area_entered(area):
	dialogue.start("not_yet")
