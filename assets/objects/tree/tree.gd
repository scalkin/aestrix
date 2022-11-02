extends StaticBody2D

var sprite_list = [
	load("res://assets/foliage/tree_1.png"),
	load("res://assets/foliage/tree_2.png"),
]

func _ready():
	$Sprite.texture = sprite_list[randi() %2]
