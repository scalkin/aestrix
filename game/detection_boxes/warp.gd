extends Area2D

export var scene: String
export var location: Vector2
export var save = true

func _on_warp_area_entered(_area):
	global.player_position = global_position
	global.travel_scene(scene, location, save)
