extends YSort

export var quest_id = 0
export var objective_id = 0

signal completed

func _process(delta):
	if get_child_count() == 1:
		queue_free()
	emit_signal("completed")
