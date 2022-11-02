tool
extends StaticBody2D

export var rock_number = 0
var sprite_list = [
	load("res://assets/objects/rocks/rock_1.png"),
	load("res://assets/objects/rocks/rock_2.png"),
	load("res://assets/objects/rocks/rock_3.png"),
]

func _process(_delta):
	$Sprite.texture = sprite_list[rock_number]
