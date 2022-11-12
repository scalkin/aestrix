tool
extends StaticBody2D

export var rock_number = 0
var sprite_list = [
	load("res://assets/environment/rocks/rock_4.png"),
	load("res://assets/environment/rocks/rock_5.png"),
	load("res://assets/environment/rocks/rock_6.png"),
	load("res://assets/environment/rocks/rock_7.png"),
	load("res://assets/environment/rocks/rock_8.png"),
	load("res://assets/environment/rocks/rock_9.png"),
	load("res://assets/environment/rocks/rock_10.png"),
	load("res://assets/environment/rocks/rock_11.png"),
]

func _process(_delta):
	if rock_number < sprite_list.size() and rock_number > -1:
		$Sprite.texture = sprite_list[rock_number]
	elif rock_number > sprite_list.size():
		rock_number = 0
	else:
		rock_number = sprite_list.size() - 1
