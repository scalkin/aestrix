extends Node2D

var text = "0"

func _physics_process(delta):
	global_position.y -= delta*25
	$Label.text = text

func _on_Timer_timeout():
	queue_free()
