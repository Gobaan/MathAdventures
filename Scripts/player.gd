extends CharacterBody2D

signal laser_shot(laser)
@export var acceleration := 10
@export var max_speed := 350
@export var rotation_speed := 250
@export var shoot_cooldown_timer := 0.3

@onready var muzzle = $Muzzle

var laser_scene = preload("res://Scenes/laser.tscn")
var shoot_cooldown = false

func _process(_delta):
	if Input.is_action_pressed("Shoot"):
		if not shoot_cooldown:
			shoot_cooldown = true
			shoot_laser()
			await get_tree().create_timer(shoot_cooldown_timer).timeout
			shoot_cooldown = false
		

func complete_wrap():
	var screen_size = get_viewport_rect().size
	global_position.x = wrap(global_position.x, 0, screen_size.x)
	global_position.y = wrap(global_position.y, 0 , screen_size.y)
		
func _physics_process(delta):
	var input_vector := Vector2(0, Input.get_axis("move_forward", "move_backward"))
	velocity += input_vector.rotated(rotation) * acceleration
	velocity = velocity.limit_length(max_speed)
	
	var direction =  Input.get_axis("rotate_right", "rotate_left")
	rotate(deg_to_rad(rotation_speed * direction * delta))
		
	if input_vector.y == 0:
		velocity = velocity.move_toward(Vector2.ZERO, 3)
		
	move_and_slide()
	complete_wrap()
		
func shoot_laser():
	var shot = laser_scene.instantiate()
	shot.global_position = muzzle.global_position
	shot.rotation = rotation
	emit_signal("laser_shot", shot)
