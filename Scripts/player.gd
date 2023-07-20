class_name Player extends CharacterBody2D

signal laser_shot(laser)
signal died

# TODO: Fix starting location not set to spawn point

@export var acceleration := 10
@export var max_speed := 350
@export var rotation_speed := 250
@export var shoot_cooldown_timer := 0.5

@onready var muzzle = $Muzzle
@onready var sprite = $Sprite2D
@onready var cshape = $CollisionShape2D
@export var spawn_position:Vector2;
@onready var player_number:int
@onready var input = $Controls/InputSynchronizer

var laser_scene = preload("res://Scenes/laser.tscn")
var shoot_cooldown = false
@export var alive = true
var shooting = false
var lives = 3

func _ready():
	if !is_multiplayer_authority(): return
	print ('ready')
	respawn()
	
	
func _process(_delta):
	if !alive or !is_multiplayer_authority(): return
	if shooting:
		if not shoot_cooldown: 
			shoot_cooldown = true
			shoot_laser()
			await get_tree().create_timer(shoot_cooldown_timer).timeout
			shoot_cooldown = false
			shooting = false



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
	global_position.x = wrap(global_position.x, 0, 1280)
	global_position.y = wrap(global_position.y, 0 , 720)
	
func shoot_laser():
	var shot = laser_scene.instantiate()
	shot.global_position = muzzle.global_position
	shot.rotation = rotation
	emit_signal("laser_shot", shot)
		
func respawn():
	if !is_multiplayer_authority(): return
	print ("Respawn:", get_multiplayer_authority())
	alive = true
	global_position = spawn_position
	print (spawn_position)
	velocity = Vector2.ZERO
	sprite.visible = true
	cshape.set_deferred("disabled", false)
	
func die():
	if alive:
		alive = false
		sprite.visible = false
		cshape.set_deferred("disabled", true)
		lives -= 1
		emit_signal("died", self)

@rpc("any_peer")
func shoot():
	shooting = true

