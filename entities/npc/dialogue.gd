extends CanvasLayer

func start(id):
	var timeline = Dialogic.start(id)
	add_child(timeline)
	get_tree().paused = true

func end_dialogue():
	get_tree().paused = false
