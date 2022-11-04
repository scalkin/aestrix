extends Node

func _ready():
	start("tutorial")

func start(dialogue_name: String):
	var dialogue = Dialogic.start(dialogue_name)
	add_child(dialogue)
