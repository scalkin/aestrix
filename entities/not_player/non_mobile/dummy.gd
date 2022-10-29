extends "res://entities/not_player/entity.gd"

func _on_hitbox_hit():
	$AnimationPlayer.play("hit")
