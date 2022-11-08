extends Area2D

signal hit
signal iframe_ended

var number_res = preload("res://game/effects/number_effect.tscn")

func _on_hitbox_area_entered(area):
	emit_signal("hit")
	var number_effect = number_res.instance()
	get_parent().get_parent().add_child(number_effect)
	number_effect.global_position = global_position + Vector2(rand_range(-2, 2), rand_range(-2, 2))
	number_effect.text = str(area.damage)
	set_deferred("monitoring", false)
	set_deferred("monitorable", false)
	$Timer.start()

func _on_Timer_timeout():
	set_deferred("monitoring", true)
	set_deferred("monitorable", true)
