extends KinematicBody2D

var health = 5

signal death

func _on_hitbox_area_entered(area):
	health -= area.damage
	if health <= 0:
		emit_signal("death")
