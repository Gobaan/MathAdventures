extends MultiplayerSynchronizer

@export var turning_direction: float;
@export var velocity = Vector2.ZERO;
@export var shooting = false;

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if !is_multiplayer_authority(): return
	if Input.is_action_pressed("Shoot"):
		get_parent().get_parent().shoot.rpc()
	velocity = Vector2(0, Input.get_axis("move_forward", "move_backward"))
	turning_direction =  Input.get_axis("rotate_right", "rotate_left")


