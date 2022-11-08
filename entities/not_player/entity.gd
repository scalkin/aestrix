extends KinematicBody2D

export var health = 5

signal death

func _on_hitbox_area_entered(area):
	health -= area.damage
	if health <= 0:
		emit_signal("death")
	set("shader_param/active", true)

func _on_hitbox_iframe_ended():
	set("shader_param/active", false)
