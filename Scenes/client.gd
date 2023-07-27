extends Node

signal died(client)
@onready var player = $Player
@export var lives = 3: 
	set(value):
		lives = value
		print ("Client.tscn: is-server?", multiplayer.is_server(), " lives: ", lives)
		if (!multiplayer.is_server()):

			$HUD.show()
			$HUD.init_lives(lives)

func _on_died():
	emit_signal("died", self)
	update_lives.rpc()
	
@rpc
func update_lives():
	lives -= 1
	
func _ready():
	$Player.connect("died", _on_died)
	lives = 3



