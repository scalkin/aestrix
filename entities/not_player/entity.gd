extends KinematicBody2D

export var health = 5
export var knockback = true

signal death

func _on_hitbox_area_entered(area):
	health -= area.damage
	if health <= 0:
		emit_signal("death")
	$Sprite.get("material").set("shader_param/active", true)
	$AnimatedSprite.get("material").set("shader_param/active", true)

func _on_hitbox_iframe_ended():
	$Sprite.get("material").set("shader_param/active", false)
	$AnimatedSprite.get("material").set("shader_param/active", false)
