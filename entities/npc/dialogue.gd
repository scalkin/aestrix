extends CanvasLayer

var quests_recieved = []

func start(id):
	Dialogic.set_variable("ozin_dagger_acquired", 3 in global.quests["completed_objectives"][0])
	Dialogic.set_variable("ozin_quest_completed", 4 in global.quests["completed_objectives"][0])
	var timeline = Dialogic.start(id)
	add_child(timeline)
	get_tree().paused = true

func end_dialogue():
	get_tree().paused = false
	Dialogic.save()

func recieve_quest(id):
	if not id in global.quests["quests_recieved"]:
		global.quests["quests_recieved"].append(int(id))
		global.save_game(global.save())

func objective_completed(quest_id, objective_id):
	if not objective_id in global.quests["completed_objectives"][int(quest_id)]:
		global.quests["completed_objectives"][int(quest_id)].append(int(objective_id))
		global.save_game(global.save())
