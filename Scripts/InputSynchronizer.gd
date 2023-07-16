extends MultiplayerSynchronizer

@export var turning_direction: int;
@export var vector = Vector2.ZERO;
@export var shooting = false;

func _enter_tree():
	set_multiplayer_authority(str(get_parent().name).to_int())
	
# Called when the node enters the scene tree for the first time.
func _ready():
	set_process(get_multiplayer_authority() == multiplayer.get_unique_id())


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Input.is_action_pressed("Shoot"):
		shoot.rpc()
		
	vector = Vector2(0, Input.get_axis("move_forward", "move_backward"))
	turning_direction =  Input.get_axis("rotate_right", "rotate_left")
	

@rpc("call_local")
func shoot():
	shooting = true
