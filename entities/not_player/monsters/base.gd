extends "res://entities/not_player/entity.gd"

var target_location = Vector2.ZERO
var start_location = Vector2.ZERO
var player_detected = false
var state = WALK
var target_vector = Vector2.ZERO
var velocity = Vector2.ZERO
var blood_res = preload("res://game/effects/particles/blood.tscn")

export var damage = 1
export var max_speed = 125
export var accel = 500
export var wander_distance = 75
export var xp = 5
export var knockback_factor = 1.0
export var animate_while_still = false

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
	var blood_effect = blood_res.instance()
	get_parent().add_child(blood_effect)
	blood_effect.global_position = global_position
	blood_effect.emitting = true
	blood_effect.amount = 16
	global.xp += xp
	$hurtbox.queue_free()
	queue_free()

func _physics_process(delta):
	if $death_timer.time_left != 0:
		print($death_timer.time_left)
		velocity = move_and_slide(velocity)
		return
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
	if not animate_while_still:
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
	velocity = global.player_direction * global.player_stats[5] * 100 * knockback_factor


func _on_death_timer_timeout():
	queue_free()
