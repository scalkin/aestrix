extends Area2D

func _process(delta):
	match get_overlapping_areas().size() != 0:
		true:
			$AnimatedSprite.frame = 1
		false:
			$AnimatedSprite.frame = 0