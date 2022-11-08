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

var hurtbox
var attack_cooldown = false
var attack_direction = RIGHT
var target_rotation = 0
var rotated = 0
var item_position = UP
var item_applied_position = 0
var trail_points = []
var hurtbox_points = []
var attack_trail_generated
var item_swing_size_list = [140, 120, 130, 120, 170, 170]
var item_held_distance_list = [17, 14, 15, 17, 15, 20]
var item_attack_speed_list = [2000, 500, 400, 1000, 10, 750]
var item_blade_length_list = [14, 6, 8, 13, 12, 20]
var item_damage_list = [5, 1, 1, 2, 3, 3]

export var swing_size = 120
export var item_held_distance = 13
export var attack_speed = 500
export var blade_length = 4
export var damage = 1
var item_sprite = 0

var trail_res = preload("res://game/effects/attack_trail.tscn")
var hurtbox_res = preload("res://game/detection_boxes/hurtbox.tscn")

func attack(delta):
	var applied_rotation_speed = ((sin((3.14*rotated)/swing_size)*1500)+(attack_speed*0.001))*delta
	match item_position:
		DOWN:
			rotate(-deg2rad(applied_rotation_speed))
			rotated += applied_rotation_speed
			if rotated >= swing_size:
				$Sprite.hide()
				var prev_rotation = rotation_degrees
				rotate(deg2rad(rotated/2))
				calculate_trail_points()
				attack_trail()
				emit_signal("attack_finished")
				flip_item_position()
				rotation_degrees = prev_rotation
				$Sprite.show()
		UP:
			rotate(deg2rad(applied_rotation_speed))
			rotated += applied_rotation_speed
			if rotated >= swing_size:
				$Sprite.hide()
				var prev_rotation = rotation_degrees
				rotate(-deg2rad(rotated/2))
				calculate_trail_points()
				attack_trail()
				emit_signal("attack_finished")
				flip_item_position()
				rotation_degrees = prev_rotation
				$Sprite.show()

func calculate_trail_points():
	trail_points = [
		Vector2(
			sin(deg2rad(swing_size/2))*item_held_distance+2,
			-cos(deg2rad(swing_size/2))*item_held_distance-2),
		Vector2(
			sin(deg2rad(3*swing_size/8))*item_held_distance+1,
			-cos(deg2rad(3*swing_size/8))*item_held_distance-1),
		Vector2(
			sin(deg2rad(swing_size/4))*item_held_distance,
			-cos(deg2rad(swing_size/4))*item_held_distance),
		Vector2(
			sin(deg2rad(swing_size/8))*item_held_distance,
			-cos(deg2rad(swing_size/8))*item_held_distance),
		Vector2(0, -(item_held_distance - 0.3)),
		Vector2(
			-sin(deg2rad(swing_size/8))*item_held_distance,
			-cos(deg2rad(swing_size/8))*item_held_distance),
		Vector2(
			-sin(deg2rad(swing_size/4))*item_held_distance,
			-cos(deg2rad(swing_size/4))*item_held_distance),
		Vector2(
			-sin(deg2rad(3*swing_size/8))*item_held_distance-1,
			-cos(deg2rad(3*swing_size/8))*item_held_distance-1),
		Vector2(
			-sin(deg2rad(swing_size/2))*item_held_distance-2,
			-cos(deg2rad(swing_size/2))*item_held_distance-2)
	]
	hurtbox_points = [
		Vector2(
			sin(deg2rad(swing_size/2))*item_held_distance-(blade_length/2),
			-cos(deg2rad(swing_size/2))*item_held_distance+(blade_length/2)),
		Vector2(0, 0),
		Vector2(
			-sin(deg2rad(swing_size/2))*item_held_distance+(blade_length/2),
			-cos(deg2rad(swing_size/2))*item_held_distance+(blade_length/2)),
		Vector2(
			-sin(deg2rad(swing_size/2))*(item_held_distance+(blade_length)),
			-cos(deg2rad(swing_size/2))*(item_held_distance+(blade_length))),
		Vector2(
			-sin(deg2rad(swing_size/4))*(item_held_distance+(blade_length)),
			-cos(deg2rad(swing_size/4))*(item_held_distance+(blade_length))),
		Vector2(0, -(item_held_distance + blade_length)),
		Vector2(
			sin(deg2rad(swing_size/4))*(item_held_distance+(blade_length)),
			-cos(deg2rad(swing_size/4))*(item_held_distance+(blade_length))),
		Vector2(
			sin(deg2rad(swing_size/2))*(item_held_distance+(blade_length)),
			-cos(deg2rad(swing_size/2))*(item_held_distance+(blade_length))),
	]

func attack_trail():
	var trail = trail_res.instance()
	get_parent().get_parent().add_child(trail)
	trail.rotation_degrees = rotation_degrees
	trail.global_position = global_position
	trail.points = trail_points
	attack_trail_generated = true
	hurtbox = hurtbox_res.instance()
	get_parent().get_parent().add_child(hurtbox)
	var hurtbox_collision_box = CollisionPolygon2D.new()
	hurtbox.add_child(hurtbox_collision_box)
	hurtbox_collision_box.rotation_degrees = rotation_degrees
	hurtbox_collision_box.global_position = global_position
	hurtbox_collision_box.polygon = hurtbox_points
	hurtbox.collision_layer = 8
	hurtbox.damage = damage
	$hurtbox_timer.start()
	attack_cooldown = true

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
	$hand.flip_h = $Sprite.flip_h

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

func update_item():
	$Sprite.texture = global.weapon_sprite_list[global.held_item_id]
	swing_size = item_swing_size_list[global.held_item_id]
	item_held_distance = item_held_distance_list[global.held_item_id]
	attack_speed = item_attack_speed_list[global.held_item_id]
	blade_length = item_blade_length_list[global.held_item_id]
	damage = item_damage_list[global.held_item_id]

func _physics_process(_delta):
	update_item()
	if rotation_degrees > 90 or rotation_degrees < -180:
		z_index = 1
	else:
		z_index = 0

func _on_hitbox_timer_timeout():
	attack_cooldown = false
	hurtbox.queue_free()
