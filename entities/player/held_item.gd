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

var attacking = false
var trail_colors = [Color(1, 1, 1, 1),Color(0.63, 0.89, 0.94, 1),Color(1,1,0.47451,1)]
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
var item_held_distance_list = [17, 14, 15, 17, 15, 20, 14]
var item_attack_speed_list = [2000, 500, 400, 1000, 10, 750, 5000]
var item_trail_color = [0, 0, 0, 0, 0, 0, 1]

export var swing_size = 120
export var item_held_distance = 13
export var attack_speed = 500
export var blade_length = 4
export var damage = 1
var item_sprite = 0

var trail_res = preload("res://game/effects/attack_trail.tscn")
var hurtbox_res = preload("res://game/detection_boxes/hurtbox.tscn")

onready var weapon_sprite = $weapon
onready var hand_sprite = $hand

func attack(delta):
	var applied_rotation_speed = ((sin((3.14*rotated)/swing_size)*1500)+(attack_speed*(0.001)))*delta*((global.player_stats[3]/5)+1)
	var direction_modifier = 1
	match item_position:
		DOWN:
			direction_modifier = -1
		UP:
			direction_modifier = 1
	rotate(direction_modifier*deg2rad(applied_rotation_speed))
	rotated += applied_rotation_speed
	if rotated >= swing_size:
		weapon_sprite.hide()
		var prev_rotation = rotation_degrees
		rotate(-direction_modifier*deg2rad(rotated/2))
		calculate_trail_points()
		attack_trail()
		emit_signal("attack_finished")
		flip_item_position()
		rotation_degrees = prev_rotation
		weapon_sprite.show()
		attacking = false

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
	trail.default_color = trail_colors[item_trail_color[global.held_item_id]]
	hurtbox = hurtbox_res.instance()
	get_parent().get_parent().add_child(hurtbox)
	var hurtbox_collision_box = CollisionPolygon2D.new()
	hurtbox.add_child(hurtbox_collision_box)
	hurtbox_collision_box.rotation_degrees = rotation_degrees
	hurtbox_collision_box.global_position = global_position
	hurtbox_collision_box.polygon = hurtbox_points
	hurtbox.collision_layer = 8
	hurtbox.collision_mask = 16
	hurtbox.damage = damage*(((global.player_stats[0]*9)/100)+1)
	$hurtbox_timer.start()
	attack_cooldown = true

func idle():
	weapon_sprite.offset.y = -item_held_distance
	match item_position:
		UP:
			item_applied_position = -swing_size/2
		DOWN:
			item_applied_position = swing_size/2
	var relative_mouse_location = get_global_mouse_position() - global_position
	var target_rotation_degrees = rad2deg(atan2(relative_mouse_location.y, relative_mouse_location.x)) + 90
	rotation_degrees = target_rotation_degrees
	rotate(deg2rad(item_applied_position))
	global.player_direction = Vector2(
		cos(deg2rad(rotation_degrees)),
		sin(deg2rad(rotation_degrees))
	)
	weapon_sprite.flip_h = (item_position == UP)
	hand_sprite.flip_h = weapon_sprite.flip_h

func start_attack():
	attacking = true
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
	weapon_sprite.texture = global.weapon_sprite_list[global.held_item_id]
	swing_size = global.weapon_swing_size_list[global.held_item_id]
	item_held_distance = item_held_distance_list[global.held_item_id]
	attack_speed = item_attack_speed_list[global.held_item_id]
	blade_length = global.weapon_blade_length_list[global.held_item_id]
	damage = global.weapon_damage_list[global.held_item_id]

func _physics_process(_delta):
	update_item()
	if rotation_degrees > 90 or rotation_degrees < -90:
		show_behind_parent = false
	else:
		show_behind_parent = true

func _on_hitbox_timer_timeout():
	attack_cooldown = false
	hurtbox.queue_free()
