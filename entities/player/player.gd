extends KinematicBody2D

enum{
	MOVE
	ATTACK
}

var input_vector = Vector2.ZERO
var velocity = Vector2.ZERO
var current_action = MOVE

onready var held_item = $held_item

func _physics_process(delta):
	input_vector = Input.get_vector("left", "right", "up", "down")
	input_vector = input_vector.normalized()
	match current_action:
		MOVE:
			move(delta)
			held_item.idle()
		ATTACK:
			attack()
			move(delta)
			held_item.attack(delta)
	if Input.is_action_just_pressed("attack") and current_action == MOVE:
		current_action = ATTACK
		held_item.start_attack()

func attack():
	#velocity = velocity.move_toward(Vector2.ZERO, 500*delta)
	#velocity = move_and_slide(velocity)
	pass

func move(delta):
	velocity = velocity.move_toward(input_vector * global.player_max_speed, global.player_accel * delta)
	velocity = move_and_slide(velocity)

func _on_held_item_attack_finished():
	current_action = MOVE
