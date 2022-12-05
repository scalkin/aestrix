extends Node2D

func _ready():
	$main.play("main")

func player_walk_left():
	$player.play("walk_left")

func player_idle_left():
	$player.play("idle_left")

func player_idle_up():
	$player.play("idle_up")

func player_walk_down():
	$player.play("walk_down")

func player_idle_down():
	$player.play("idle_down")

func dialogue():
	dialogue.start("escape_1")
