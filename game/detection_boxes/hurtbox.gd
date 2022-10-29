extends Area2D

var damage = 1

signal hit

func _on_hurtbox_area_entered(_area):
	emit_signal("hit")
