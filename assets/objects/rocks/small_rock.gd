tool
extends StaticBody2D

export var rock_number = 0
var sprite_list = [
	load("res://assets/objects/rocks/rock_4.png"),
	load("res://assets/objects/rocks/rock_5.png"),
	load("res://assets/objects/rocks/rock_6.png"),
	load("res://assets/objects/rocks/rock_7.png"),
	load("res://assets/objects/rocks/rock_8.png"),
	load("res://assets/objects/rocks/rock_9.png"),
	load("res://assets/objects/rocks/rock_10.png"),
	load("res://assets/objects/rocks/rock_11.png"),
]

func _process(_delta):
	if rock_number < sprite_list.size() and rock_number > 0:
		$Sprite.texture = sprite_list[rock_number]
	else:
		rock_number = 0
