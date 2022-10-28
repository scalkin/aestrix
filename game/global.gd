extends Node2D

enum{
	MOUSE
	CONTROLLER
}

var player_accel = 500
var player_max_speed = 200
export var held_item_id = 0
var inventory = [1, 0]
var target_mode = MOUSE
var last_mouse_pos = Vector2.ZERO

func _process(_delta):
	var controller_input_vector = Vector2.ZERO
	controller_input_vector.x = Input.get_axis("target_left", "target_right")
	controller_input_vector.y = Input.get_axis("target_up", "target_down")
	controller_input_vector = controller_input_vector.normalized()
	if Input.is_action_just_pressed("ui_focus_next") and OS.is_debug_build():
		match held_item_id:
			0:
				held_item_id = 1
			1:
				held_item_id = 0
	if controller_input_vector != Vector2.ZERO:
		target_mode = CONTROLLER
	elif get_local_mouse_position() != last_mouse_pos:
		last_mouse_pos = get_local_mouse_position()
		target_mode = MOUSE
	match target_mode:
		MOUSE:
			pass
		CONTROLLER:
			Input.warp_mouse_position((get_viewport().size/2)+(controller_input_vector*250))
			

