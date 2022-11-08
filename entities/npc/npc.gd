extends StaticBody2D

export var dialogic_timeline = "wilfred_1"

func _on_Area2D_area_entered(_area):
	dialogue.start(dialogic_timeline)
