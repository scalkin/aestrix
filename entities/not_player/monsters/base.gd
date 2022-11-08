extends "res://entities/not_player/entity.gd"

var target_location = Vector2.ZERO
var start_location = Vector2.ZERO
var player_detected = false
var velocity = Vector2.ZERO

export var damage = 1
export var max_speed = 175
export var accel = 500
export var wander_distance = 75

signal player_detected

func _ready():
	$hurtbox.damage = damage
# warning-ignore:return_value_discarded
	connect("death", self, "on_death")
	start_location = global_position
	target_location = start_location

func on_death():
	queue_free()

func _physics_process(delta):
	var max_wander_speed = 0.25*max_speed
	if player_detected:
		target_location = $player_detect.get_overlapping_areas()[0].global_position
	elif (target_location - global_position).length() < 5:
			target_location = start_location + Vector2(
				rand_range(-wander_distance, wander_distance),
				rand_range(-wander_distance/2, wander_distance/2))
	if $world_detect.get_overlapping_bodies().size() > 0:
		target_location = global_position + Vector2(
				rand_range(-wander_distance/2, wander_distance/2),
				rand_range(-wander_distance/2, wander_distance/2))
	$world_detect.rotation = atan2(velocity.y, velocity.x) - 1.570796
	var target_vector = (target_location - global_position).normalized()
	if player_detected:
		velocity = velocity.move_toward(target_vector*max_speed, accel*delta)
	else:
		velocity = velocity.move_toward(target_vector*max_wander_speed, accel*delta)
	velocity = move_and_slide(velocity)
	$AnimatedSprite.flip_h = target_vector.x < 0
func _on_player_detect_area_entered(area):
	player_detected = true
	emit_signal("player_detected")
	target_location = area.global_position

func _on_player_detect_area_exited(_area):
	player_detected = false

func _on_hurtbox_hit():
	velocity = velocity*0.25
