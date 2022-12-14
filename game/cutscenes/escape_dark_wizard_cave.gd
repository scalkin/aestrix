extends Node2D

func _ready():
	$main.play("main")
	pass

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

func change_scene():
	var save = global.save()
	save["weapons_inventory"][6] = 0
	save["held_item_id"] = 1
	save["current_scene"] = "res://levels/towns/achenbourne.tscn"
	save["player_position_x"] = 713
	save["player_position_y"] = -691
	global.save_game(save)
	global.load_game()
