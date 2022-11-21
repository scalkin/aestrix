extends "res://entities/not_player/entity.gd"

var target_location = Vector2.ZERO
var start_location = Vector2.ZERO
var player_detected = false
var state = WALK
var target_vector = Vector2.ZERO
var velocity = Vector2.ZERO

export var damage = 1
export var max_speed = 125
export var accel = 500
export var wander_distance = 75
export var xp = 5

signal player_detected

enum{#state
	IDLE,
	WALK
}

func _ready():
	$hurtbox.damage = damage
# warning-ignore:return_value_discarded
	connect("death", self, "on_death")
	start_location = global_position
	target_location = start_location

func on_death():
	global.xp += xp
	queue_free()

func _physics_process(delta):
	if not $AnimatedSprite.playing:
		$AnimatedSprite.frame = 0
	if player_detected:
		state = WALK
	var max_wander_speed = 0.25*max_speed
	if player_detected:
		target_location = $player_detect.get_overlapping_areas()[0].global_position
	elif (target_location - global_position).length() < 15 and state == WALK:
			$state_timer.start(rand_range(0.5, 2))
			state = IDLE
	if $world_detect.get_overlapping_bodies().size() > 0:
		target_location = global_position + Vector2(
				rand_range(-wander_distance/2, wander_distance/2),
				rand_range(-wander_distance/2, wander_distance/2))
	$world_detect.rotation = atan2(velocity.y, velocity.x) - deg2rad(90)
	target_vector = (target_location - global_position).normalized()*state
	$AnimatedSprite.playing = state == WALK
	if player_detected:
		velocity = velocity.move_toward(target_vector*max_speed, accel*delta)
	else:
		velocity = velocity.move_toward(target_vector*max_wander_speed, accel*delta)
	if $soft_collision.get_overlapping_areas().size() != 0:
		velocity -= global_position.direction_to($soft_collision.get_overlapping_areas()[0].global_position).normalized()*10
	velocity = move_and_slide(velocity)

func _on_player_detect_area_entered(area):
	player_detected = true
	emit_signal("player_detected")
	target_location = area.global_position

func _on_player_detect_area_exited(_area):
	player_detected = false

func _on_hurtbox_hit():
	velocity = velocity*-1
	$AnimatedSprite.flip_h = velocity.x < 0

func _on_state_timer_timeout():
	state = WALK
	while true:
		target_location = start_location + Vector2(
			rand_range(-wander_distance, wander_distance),
			rand_range(-wander_distance/2, wander_distance/2))
		if global_position.distance_to(target_location) > 15:
			break

func _on_sprite_timer_timeout():
	if velocity:
		$AnimatedSprite.flip_h = velocity.x < 0


func _on_hitbox_hit():
	velocity = move_and_slide((global.player_stats[5]+1)*50*(get_viewport().get_mouse_position()-get_viewport().size/8).normalized()*global.player_stats[5])
