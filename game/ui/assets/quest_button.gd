extends Button

var id = 0

func _process(_delta):
	text = global.quests["names"][id]

func _on_Button_pressed():
	ui.selected_quest = id
