extends CanvasLayer

func _ready():
	$TabContainer.visible = false

func _physics_process(_delta):
	for x in get_children():
		x.visible = $TabContainer.visible
	get_tree().paused = $TabContainer.visible
	if Input.is_action_just_pressed("menu"):
		$TabContainer.visible = not $TabContainer.visible
