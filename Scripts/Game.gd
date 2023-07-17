extends Node2D

@onready var lasers = $Lasers

@onready var asteroids = $Asteroids
@onready var hud = $UI/HUD
@onready var spawn_positions = $SpawnPositions

@onready var game_over_screen  = $UI/GameOver
@onready var start_screen = $UI/Start
@onready var player_scene = preload("res://Scenes/player.tscn")
var asteroid_scene = preload("res://Scenes/asteroid.tscn")
var player_count = 0
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
	if "--server" in OS.get_cmdline_args():
		print ("Started server")
		_on_host()
	print ("Code started")
	score = 0
	lives = 3
	player_count = 0
	game_over_screen.visible = false
	
	start_screen.connect("hosted", _on_host)
	start_screen.connect("joined", _on_join)
	start_screen.connect("single_player_started", _on_single_player)
	
	for asteroid in asteroids.get_children():
		asteroid.connect("exploded", _on_asteroid_exploded)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if Input.is_action_just_pressed("Reset"):
		get_tree().reload_current_scene()


func _on_host():
	start_screen.hide()
	hud.show()
	multiplayer.peer_connected.connect(add_player)

func _on_single_player():
	start_screen.hide()
	hud.show()
	add_player(multiplayer.get_unique_id())

func _on_join():
	start_screen.hide()
	hud.show()

func add_player(peer_id):
	print (peer_id, ":", player_count)
	var new_player = player_scene.instantiate()
	new_player.name = str(peer_id)
	new_player.connect("laser_shot", _on_player_laser_shot)
	new_player.connect("died", _on_player_died)
	new_player.spawn = spawn_positions.get_child(player_count)
	add_child(new_player)
	new_player.respawn()
	player_count += 1 
	spawn_asteroid(Vector2(50, 50), Asteroid.AsteroidSize.LARGE)


func _on_player_laser_shot(laser):
	$LaserSound.play()
	lasers.add_child(laser, true)


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
	asteroids.call_deferred('add_child', asteroid, true)

func _on_player_died(player):
	$PlayerDied.play()
	player.global_position = player.spawn.global_position
	lives = player.lives
	if lives <= 0:
		await get_tree().create_timer(2).timeout
		game_over_screen.visible = true
	else:
		await get_tree().create_timer(1).timeout
		while !player.spawn.get_child(0).is_empty:
			await get_tree().create_timer(0.1).timeout
		player.respawn()
