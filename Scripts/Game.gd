extends Node2D

@onready var lasers = $Lasers
@onready var player = $Player
@onready var asteroids = $Asteroids
@onready var hud = $UI/HUD
@onready var player_spawn_position = $PlayerSpawnPosition
@onready var player_spawn_area = $PlayerSpawnPosition/PlayerSpawnArea
@onready var game_over_screen  = $UI/GameOver
@onready var start_screen = $UI/Start

var asteroid_scene = preload("res://Scenes/asteroid.tscn")
var score:
	set(value):
		score = value
		hud.score = score

var lives:
	set(value):
		lives = value
		hud.init_lives(value)
		
# Called when the node enters the scene tree for the first time.
func _ready():
	score = 0
	lives = 3
	game_over_screen.visible = false
	player.connect("laser_shot", _on_player_laser_shot)
	player.connect("died", _on_player_died)
	start_screen.connect("host", _on_host)
	
	for asteroid in asteroids.get_children():
		asteroid.connect("exploded", _on_asteroid_exploded)

func _on_host():
	add_player(multiplayer.get_unique_id())
	
func add_player(peer_id):
	var new_player = player.instantiate()
	new_player.name = str(peer_id)
	add_child(player)
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if Input.is_action_just_pressed("Reset"):
		get_tree().reload_current_scene()

func _on_player_laser_shot(laser):
	$LaserSound.play()
	lasers.add_child(laser)

func _on_asteroid_exploded(current_position, size):
	$AsteroidHitSound.play()
	score += Asteroid.get_points(size)
	for i in range(2):
		spawn_asteroid(current_position, size + 1)
	
func spawn_asteroid(current_position, size):
	if size == Asteroid.AsteroidSize.FINISHED:
		return
		
	var asteroid = asteroid_scene.instantiate()
	asteroid.global_position = current_position
	asteroid.size = size
	asteroid.connect("exploded", _on_asteroid_exploded)
	asteroids.call_deferred("add_child", asteroid)

func _on_player_died():
	$PlayerDied.play()
	player.global_position = player_spawn_position.global_position
	lives -= 1
	if lives <= 0:
		await get_tree().create_timer(2).timeout
		game_over_screen.visible = true
	else:
		await get_tree().create_timer(1).timeout
		while !player_spawn_area.is_empty:
			await get_tree().create_timer(0.1).timeout
		player.respawn(player_spawn_position.global_position)
