extends Node2D

func _ready():
	$player_animate.play("player_walk")
	$main.play("main")

func player_stopped():
	$dark_wizard_animate.play("walk")

func player_stopped_2():
	$player_animate.play("idle_right")

func dark_wizards_arrive():
	$dark_wizard_animate.play("RESET")

func player_stopped_3():
	$YSort/player.flip_h = true
	$CanvasLayer/ColorRect2.queue_free()
	dialogue.start("kidnapped_1")

func change_scene():
	var save = global.save()
	save["weapons_inventory"][6] = 0
	save["held_item_id"] = 1
	save["current_scene"] = "res://levels/dungeons/dungeon_2.tscn"
	save["player_position_x"] = 0
	save["player_position_y"] = 0
	global.save_game(save)
	global.load_game()
