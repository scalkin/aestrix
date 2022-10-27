extends Node2D

signal attack_finished

enum{
	RIGHT
	LEFT
}

var attack_direction = RIGHT
var target_rotation = 0
var rotated = 0
export var rotation_speed = 200

func attack(delta):
	var applied_rotation_speed = ((sin((3.14*rotated)/90)*100)+150)*delta
	print(applied_rotation_speed)
	match attack_direction:
		LEFT:
			rotate(-deg2rad(applied_rotation_speed))
			rotated += applied_rotation_speed
			if rotated >= 90:
				rotate(deg2rad(22.5))
				emit_signal("attack_finished")
		RIGHT:
			rotate(deg2rad(applied_rotation_speed))
			rotated += applied_rotation_speed
			if rotated >= 90:
				rotate(deg2rad(-22.5))
				emit_signal("attack_finished")

func idle():
	var relative_mouse_location = get_global_mouse_position() - global_position
	rotation_degrees = rad2deg(atan2(relative_mouse_location.y, relative_mouse_location.x)) + 90
	$Sprite.flip_h = not (rotation_degrees < 0 or rotation_degrees > 180)
	$Hand.flip_h = $Sprite.flip_h

func start_attack():
		rotated = 0
		if (rotation_degrees < 0 or rotation_degrees > 180):
			attack_direction = LEFT
			rotate(deg2rad(45))
		else:
			attack_direction = RIGHT
			rotate(deg2rad(-45))
