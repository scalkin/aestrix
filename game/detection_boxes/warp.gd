extends Area2D

export var scene: String
export var location: Vector2

func _on_warp_area_entered(area):
	global.travel_scene(scene, location)
