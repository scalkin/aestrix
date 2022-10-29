extends Area2D

signal hit

var number_res = preload("res://game/effects/number_effect.tscn")

func _on_hitbox_area_entered(area):
	emit_signal("hit")
	var number_effect = number_res.instance()
	get_parent().get_parent().add_child(number_effect)
	number_effect.global_position = global_position + Vector2(rand_range(-2, 2), rand_range(-2, 2))
	number_effect.text = str(area.damage)
