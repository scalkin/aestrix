extends KinematicBody2D

enum{
	MOVE
	ATTACK
}

var input_vector = Vector2.ZERO
var prev_input_vector = Vector2.ZERO
var velocity = Vector2.ZERO
var current_action = MOVE
var loaded = false
var free_cam = false
var free_cam_toggle = false
var stationary_cam = false
var last_camera_location = Vector2.ZERO

onready var state_machine = $AnimationTree.get("parameters/playback")
onready var held_item = $held_item
onready var camera = $Camera2D

func _ready():
	$Sprite.get("material").set("shader_param/active", false)
# warning-ignore:return_value_discarded
	global.connect("game_saved", self, "save_player_position")
# warning-ignore:return_value_discarded
	global.connect("player_position_updated", self, "set_player_position")
	global_position = global.start_location

func set_player_position():
	print("reached")
	print(global.player_position)
	global_position = global.player_position
	print(global_position)

func _physics_process(delta):
	$AnimationTree.active = !free_cam
	if OS.is_debug_build():
		var zoom =  (Input.get_action_strength("zoom_out") - Input.get_action_strength("zoom_in")) / 50
		camera.zoom.x = clamp(camera.zoom.x + zoom, 0.5, 5.0)
		camera.zoom.y = camera.zoom.x
		if Input.is_action_just_pressed("free_cam"):
			free_cam_toggle = !free_cam_toggle
		if Input.is_action_pressed("free_cam_hold"):
			free_cam = true
		else:
			free_cam = free_cam_toggle
		if Input.is_action_just_pressed("stationary_cam"):
			stationary_cam = !stationary_cam
		if stationary_cam:
			camera.global_position = last_camera_location
			camera.smoothing_speed = 0
		else:
			last_camera_location = camera.global_position
			camera.smoothing_speed = 10
	global_position = Vector2(round(global_position.x), round(global_position.y))
	input_vector = Input.get_vector("left", "right", "up", "down")
	input_vector = input_vector.normalized()
	if input_vector:
		prev_input_vector = input_vector
		global.player_direction = prev_input_vector
		state_machine.travel("Walk")
		$AnimationTree.set("parameters/Idle/blend_position", input_vector)
		$AnimationTree.set("parameters/Walk/blend_position", input_vector)
	else:
		state_machine.travel("Idle")
	match current_action:
		MOVE:
			move(delta)
			held_item.idle()
		ATTACK:
			attack()
			move(delta)
			held_item.attack(delta)
	if Input.is_action_just_pressed("attack") and current_action == MOVE and not get_tree().paused and not $held_item.attack_cooldown:
		current_action = ATTACK
		held_item.start_attack()

func attack():
	#velocity = velocity.move_toward(Vector2.ZERO, 500*delta)
	#velocity = move_and_slide(velocity)
	pass

func move(delta):
	velocity = velocity.move_toward(input_vector * global.player_max_speed, global.player_accel * delta)
	if free_cam:
		camera.global_position += velocity/50
	else:
		velocity = move_and_slide(velocity)

func _on_held_item_attack_finished():
	current_action = MOVE

func save_player_position():
	global.player_position = global_position
	OS.alert("Set global player position to " + str(global_position))

func _on_hitbox_area_entered(area):
	global.health -= area.damage*(((global.player_stats[2]*-9)+90)/100)
	$Sprite.get("material").set("shader_param/active", true)


func _on_hitbox_iframe_ended():
	$Sprite.get("material").set("shader_param/active", false)
