extends YSort

export var quest_id = 0
export var objective_id = 0

signal completed

func _ready():
	if objective_id in global.quests["completed_objectives"]:
		queue_free()

func _process(delta):
	if get_child_count() == 1:
		emit_signal("completed")
		global.quests["completed_objectives"].append(objective_id)
		global.save_game(global.save())
		queue_free()
