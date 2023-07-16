extends Area2D

@export var speed := 500

var movement_vector := Vector2(0, - 1)

func _physics_process(delta):
	if !is_multiplayer_authority(): return
	global_position += movement_vector.rotated(rotation) * speed * delta

func _on_visible_on_screen_notifier_2d_screen_exited():
	queue_free()

func _on_area_entered(area):
	if area is Asteroid:
		var asteroid = area
		asteroid.explode()
		queue_free()
