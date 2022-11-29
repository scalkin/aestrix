extends Node2D

func _ready():
	$player_animate.play("player_walk")
	$main.play("main")
