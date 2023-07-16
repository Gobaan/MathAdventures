class_name Player extends CharacterBody2D

signal laser_shot(laser)
signal died

# TODO: Fix starting location not set to spawn point

@export var acceleration := 10
@export var max_speed := 350
@export var rotation_speed := 250
@export var shoot_cooldown_timer := 0.3

@onready var muzzle = $Muzzle
@onready var sprite = $Sprite2D
@onready var cshape = $CollisionShape2D
@onready var spawn;
@onready var input = $InputSynchronizer

var laser_scene = preload("res://Scenes/laser.tscn")
var shoot_cooldown = false
@export var alive = true
var lives = 3

func _process(_delta):
	if !alive or !is_multiplayer_authority(): return
	if input.shooting:
		if not shoot_cooldown:
			shoot_cooldown = true
			shoot_laser()
			await get_tree().create_timer(shoot_cooldown_timer).timeout
			shoot_cooldown = false
			input.shooting = false


func _physics_process(delta):
	if !alive or !is_multiplayer_authority(): return
	velocity += input.vector.rotated(rotation) * acceleration
	velocity = velocity.limit_length(max_speed)
	rotate(deg_to_rad(rotation_speed * input.turning_direction * delta))
	
	if input.vector.y == 0:
		velocity = velocity.move_toward(Vector2.ZERO, 3)

	move_and_slide()
	complete_wrap()
	
func complete_wrap():
	var screen_size = get_viewport_rect().size
	global_position.x = wrap(global_position.x, 0, screen_size.x)
	global_position.y = wrap(global_position.y, 0 , screen_size.y)


func shoot_laser():
	var shot = laser_scene.instantiate()
	shot.global_position = muzzle.global_position
	shot.rotation = rotation
	emit_signal("laser_shot", shot)

func die():
	if alive:
		alive = false
		sprite.visible = false
		cshape.set_deferred("disabled", true)
		lives -= 1
		emit_signal("died", self)
		
		
func respawn():
	alive = true
	global_position = spawn.global_position
	velocity = Vector2.ZERO
	sprite.visible = true
	cshape.set_deferred("disabled", false)
