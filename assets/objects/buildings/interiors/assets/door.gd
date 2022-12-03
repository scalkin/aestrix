tool
extends Area2D

export var texture = 0

const textures = [preload("res://assets/objects/assets/door_exterior.tres"), preload("res://assets/objects/assets/door_interior.tres")]

func _process(_delta):
	$AnimatedSprite.frames = textures[texture]
	match get_overlapping_areas().size() != 0:
		true:
			$AnimatedSprite.frame = 1
		false:
			$AnimatedSprite.frame = 0
