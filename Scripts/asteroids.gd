class_name Asteroid extends Area2D

signal exploded()

var movement_vector := Vector2(0, -1)
var speed := 50.0

enum AsteroidSize{LARGE, MEDIUM, SMALL, FINISHED}
@export var size : AsteroidSize

@onready var sprite = $Sprite2D
@onready var cshape = $CollisionShape2D

static func get_points(asteroid_size) -> int:
		match asteroid_size:
			AsteroidSize.LARGE:
				return 50
			AsteroidSize.MEDIUM:
				return 100
			AsteroidSize.SMALL:
				return 200
			_:
				return 0

func complete_wrap():
	var radius =  cshape.shape.radius
	var screen_size = get_viewport_rect().size
	global_position.x = wrap(global_position.x, -radius, 1280 + radius)
	global_position.y = wrap(global_position.y, -radius , 720 + radius)

func _ready():
	set_process(get_multiplayer_authority() == multiplayer.get_unique_id())
	set_physics_process(get_multiplayer_authority() == multiplayer.get_unique_id())
	rotation = randf_range(0, 2*PI)
	match size:
		AsteroidSize.LARGE:
			speed = randf_range(speed, speed * 2)
			sprite.texture = preload("res://assets/kenney_space-shooter-redux/PNG/Meteors/meteorBrown_big1.png")
			cshape.shape = preload("res://Resources/asteroid_cshape_large.tres")
		AsteroidSize.MEDIUM:
			speed = randf_range(speed * 2, speed * 3)
			sprite.texture = preload("res://assets/kenney_space-shooter-redux/PNG/Meteors/meteorBrown_med1.png")
			cshape.shape = preload("res://Resources/asteroid_cshape_medium.tres")
		AsteroidSize.SMALL:
			speed = randf_range(speed * 2, speed * 4)
			sprite.texture = preload("res://assets/kenney_space-shooter-redux/PNG/Meteors/meteorBrown_small1.png")
			cshape.shape = preload("res://Resources/asteroid_cshape_small.tres")
	
func _physics_process(delta):
	if !is_multiplayer_authority(): return
	global_position += movement_vector.rotated(rotation) * speed * delta
	complete_wrap()

func explode():
	if !is_multiplayer_authority(): return 
	emit_signal("exploded", global_position, size)
	queue_free()


func _on_body_entered(body):
	if body is Player:
		var player = body
		player.die() # Replace with function body.
