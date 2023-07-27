extends Area2D

@export var speed := 500

var movement_vector := Vector2(0, - 1)
func _ready():
	set_process(get_multiplayer_authority() == multiplayer.get_unique_id())
	set_physics_process(get_multiplayer_authority() == multiplayer.get_unique_id())

func _physics_process(delta):
	global_position += movement_vector.rotated(rotation) * speed * delta

func _on_visible_on_screen_notifier_2d_screen_exited():
	if !is_multiplayer_authority(): return 
	# Do i have to free this on both sides?
	queue_free()


func _on_area_entered(area):
	# set_on_entered(get_multiplayer_authority() == multiplayer.get_unique_id())?
	if !is_multiplayer_authority(): return 
	if area is Asteroid:
		var asteroid = area
		asteroid.explode()
		queue_free()
