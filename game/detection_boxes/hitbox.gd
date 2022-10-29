extends Area2D

signal hit

func _on_hitbox_area_entered(_area):
	emit_signal("hit")
	print("hit")
