extends Node2D

@onready var lasers = $Lasers

@onready var asteroids = $Asteroids
@onready var spawn_positions = $SpawnPositions
@onready var players = $Players
@onready var game_over_screen  = $UI/GameOver
@onready var start_screen = $UI/Start
@onready var client_scene = preload("res://Scenes/client.tscn")

var asteroid_scene = preload("res://Scenes/asteroid.tscn")
var player_count = 0
var asteroid_count = 0
# Called when the node enters the scene tree for the first time.
func _ready():

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
		
	if Input.is_action_just_pressed("SpawnAsteroid") and multiplayer.is_server():
		spawn_new_asteroid()


func _on_host():
	start_screen.hide()
	print ("Game.TSCN:hosting")
	multiplayer.peer_connected.connect(add_player)

func _on_single_player():
	start_screen.hide()
	add_player(multiplayer.get_unique_id())

func _on_join():
	start_screen.hide()


func add_player(peer_id):
	var client = client_scene.instantiate()
	var player = client.get_node("Player")
	client.name = str(peer_id)
	player.spawn_position = spawn_positions.get_child(player_count).global_position
	player.player_number = player_count
	player.connect("laser_shot", _on_player_laser_shot)
	client.connect("died", _on_player_died)
	players.add_child(client, true)
	player_count += 1 

func spawn_new_asteroid():
	var asteroid_spawn_location = $AsteroidPath/AsteroidSpawnLocation
	asteroid_spawn_location.progress_ratio = randf()
	var pos = asteroid_spawn_location.position
	var direction = asteroid_spawn_location.rotation + PI / 2
	var rot = direction + randf_range(-PI/4, PI/4)
	spawn_asteroid(pos, Asteroid.AsteroidSize.LARGE, rot)
	

func _on_player_laser_shot(laser):
	$LaserSound.play()
	lasers.add_child(laser, true)


func _on_asteroid_exploded(current_position, size):
	$AsteroidHitSound.play()
	#score += Asteroid.get_points(size)
	asteroid_count -= 1
	for i in range(2):
		spawn_asteroid(current_position, size + 1, randf_range(0, 2*PI))


func spawn_asteroid(current_position, size, rotation):
	if size == Asteroid.AsteroidSize.FINISHED:
		return
	asteroid_count += 1
	var asteroid = asteroid_scene.instantiate()
	asteroid.position = current_position
	asteroid.size = size
	asteroid.rotation = rotation
	asteroid.connect("exploded", _on_asteroid_exploded)
	asteroids.call_deferred('add_child', asteroid, true)

func _on_player_died(client):
	$PlayerDied.play()
	client.player.global_position = client.player.spawn_position
	
	var total_lives = 0
	for p in players.get_children():
		total_lives += p.lives

	if total_lives <= 0:
		await get_tree().create_timer(2).timeout
		game_over_screen.show_gameover.rpc()
	elif client.lives > 0:
		await get_tree().create_timer(1).timeout
		var spawn_position = spawn_positions.get_child(client.player.player_number).get_child(0)
		while !spawn_position.is_empty:
			await get_tree().create_timer(0.1).timeout
		client.player.respawn()



func _on_timer_timeout():
	if player_count > 1 and asteroid_count < 10:
		spawn_new_asteroid() 
