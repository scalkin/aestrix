extends Area2D

export var quest_id = 0
export var objective_id = 0

signal completed

func _ready():
	if objective_id in global.quests["completed_objectives"]:
		queue_free()

func _on_quest_checkpoint_area_entered(_area):
	emit_signal("completed")
	global.quests["completed_objectives"][quest_id].append(objective_id)
	global.save_game(global.save())
	queue_free()
