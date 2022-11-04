extends Node

enum{
	EXPLORING,
	VILLAGE
}

var tracks = [
	load("res://game/effects/music/assets/cave_theme_1.wav"),#0
	load("res://game/effects/music/assets/cave_theme_2.wav"),#1
	load("res://game/effects/music/assets/dungeon_theme_1.wav"),#2
	load("res://game/effects/music/assets/dungeon_theme_2.wav"),#3
	load("res://game/effects/music/assets/Fanfare_1.wav"),#4
	load("res://game/effects/music/assets/Fanfare_2.wav"),#5
	load("res://game/effects/music/assets/Fanfare_3.wav"),#6
	load("res://game/effects/music/assets/field_theme_1.wav"),#7
	load("res://game/effects/music/assets/field_theme_2.wav"),#8
	load("res://game/effects/music/assets/Game_Over_1.wav"),#9
	load("res://game/effects/music/assets/Game_Over_2.wav"),#10
	load("res://game/effects/music/assets/Game_Over_3.wav"),#11
	load("res://game/effects/music/assets/night_theme_1.wav"),#12
	load("res://game/effects/music/assets/night_theme_2.wav"),#13
	load("res://game/effects/music/assets/sea_theme_1.wav"),#14
	load("res://game/effects/music/assets/sea_theme_2.wav"),#15
	load("res://game/effects/music/assets/Track_#1.wav"),#16
	load("res://game/effects/music/assets/Track_#2.wav"),#17
	load("res://game/effects/music/assets/Track_#3.wav"),#18
	load("res://game/effects/music/assets/Track_#4.wav"),#19
	load("res://game/effects/music/assets/Track_#5.wav"),#20
	load("res://game/effects/music/assets/Track_#6.wav")#21
]

var track_list = [[7, 18, 19, 20], [6, 21]]
var state = EXPLORING setget set_state
var current_track = 0
var volume = 7

onready var music = $AudioStreamPlayer

func shuffle_tracks():
	for x in track_list:
		x.shuffle()

func set_state(value):
	music.stop()
	state = value

func _on_AudioStreamPlayer_finished():
	current_track += 1
	if current_track > (track_list[state].size() - 1):
		current_track = 0
		shuffle_tracks()
	$Timer.start()

func _on_Timer_timeout():
	music.stream = tracks[track_list[state][current_track]]
	music.play()

func _process(_delta):
	music.volume_db = (5*volume)-40
	if Input.is_action_just_pressed("ui_focus_prev") and OS.is_debug_build():
		_on_AudioStreamPlayer_finished()
