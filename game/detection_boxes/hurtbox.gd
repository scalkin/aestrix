extends Area2D

var damage = 1

signal hit

func _on_hurtbox_area_entered(_area):
	emit_signal("hit")
	set_deferred("monitoring", false)
	set_deferred("monitorable", false)
	$Timer.start()

func _on_Timer_timeout():
	set_deferred("monitoring", true)
	set_deferred("monitorable", true)
