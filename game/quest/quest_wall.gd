extends YSort

export var quest_id = 0
export var objective_id = 0
export var mode = 0
signal completed

func _ready():
	if objective_id in global.quests["completed_objectives"][quest_id]:
		queue_free()

func _process(_delta):
	match mode:
		0:
			if get_child_count() == 1:
				emit_signal("completed")
				global.quests["completed_objectives"][quest_id].append(objective_id)
				global.save_game(global.save())
				queue_free()
		1:
			if objective_id in global.quests["completed_objectives"][quest_id]:
				emit_signal("completed")
				global.save_game(global.save())
				queue_free()
