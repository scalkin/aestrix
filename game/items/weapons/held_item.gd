extends Node2D

signal attack_finished

enum{
	RIGHT
	LEFT
}
enum{
	UP
	DOWN
}

var attack_direction = RIGHT
var target_rotation = 0
var rotated = 0
var item_position = UP
var item_applied_position = 0
var attack_positions = []
var attack_trail_generated

export var swing_size = 120
export var item_held_distance = 13
export var rotation_speed = 200

var trail_effect = preload("res://game/effects/attack_trail.tscn")

func attack(delta):
	var applied_rotation_speed = ((sin((3.14*rotated)/swing_size)*2000)+0.001)*delta
	match item_position:
		DOWN:
			rotate(-deg2rad(applied_rotation_speed))
			rotated += applied_rotation_speed
			if rotated >= swing_size/2 and not attack_trail_generated:
				calculate_trail_points()
				attack_trail()
			if rotated >= swing_size:
				emit_signal("attack_finished")
				flip_item_position()
		UP:
			rotate(deg2rad(applied_rotation_speed))
			rotated += applied_rotation_speed
			if rotated >= swing_size/2 and not attack_trail_generated:
				calculate_trail_points()
				attack_trail()
			if rotated >= swing_size:
				emit_signal("attack_finished")
				flip_item_position()

func calculate_trail_points():
	#TODO add 2 more points in between middle and ends
	attack_positions = [
		Vector2(
			sin(deg2rad(swing_size/2))*item_held_distance+2,
			-cos(deg2rad(swing_size/2))*item_held_distance-2),
		Vector2(
			sin(deg2rad(swing_size/4))*item_held_distance,
			-cos(deg2rad(swing_size/4))*item_held_distance),
		Vector2(0, -12.5),
		Vector2(
			-sin(deg2rad(swing_size/4))*item_held_distance,
			-cos(deg2rad(swing_size/4))*item_held_distance),
		Vector2(
			-sin(deg2rad(swing_size/2))*item_held_distance-2,
			-cos(deg2rad(swing_size/2))*item_held_distance-2)
		]

func attack_trail():
	var trail = trail_effect.instance()
	get_parent().get_parent().add_child(trail)
	trail.rotation_degrees = rotation_degrees
	trail.global_position = global_position
	trail.points = attack_positions
	attack_trail_generated = true

func idle():
	$Sprite.offset.y = -item_held_distance
	match item_position:
		UP:
			item_applied_position = -(swing_size/2)
		DOWN:
			item_applied_position = (swing_size/2)
	var relative_mouse_location = get_global_mouse_position() - global_position
	rotation_degrees = rad2deg(atan2(relative_mouse_location.y, relative_mouse_location.x)) + 90
	rotate(deg2rad(item_applied_position))
	$Sprite.flip_h = (item_position == UP)
	$Hand.flip_h = $Sprite.flip_h

func start_attack():
	attack_trail_generated = false
	rotated = 0
	if (rotation_degrees < 0 or rotation_degrees > 180):
		attack_direction = LEFT
	else:
		attack_direction = RIGHT

func flip_item_position():
	match item_position:
		UP:
			item_position = DOWN
		DOWN:
			item_position = UP
