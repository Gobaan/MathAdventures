extends Node2D

@onready var lasers = $Lasers
@onready var player = $Player
@onready var asteroids = $Asteroids

var asteroid_scene = preload("res://Scenes/asteroid.tscn")
# Called when the node enters the scene tree for the first time.
func _ready():
	player.connect("laser_shot", _on_player_laser_shot)
	
	for asteroid in asteroids.get_children():
		asteroid.connect("exploded", _on_asteroid_exploded)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if Input.is_action_just_pressed("Reset"):
		get_tree().reload_current_scene()

func _on_player_laser_shot(laser):
	lasers.add_child(laser)

func _on_asteroid_exploded(pos, size):
	
	for i in range(2):
		spawn_asteroid(pos, size + 1)
	
func spawn_asteroid(pos, size):
	if size == Asteroid.AsteroidSize.FINISHED:
		return
		
	var asteroid = asteroid_scene.instantiate()
	asteroid.global_position = pos
	asteroid.size = size
	asteroid.connect("exploded", _on_asteroid_exploded)
	asteroids.call_deferred("add_child", asteroid)
