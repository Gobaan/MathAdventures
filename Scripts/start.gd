extends CanvasLayer

signal hosted
signal single_player_started
signal joined

@onready var mainMenu = $MainMenu
@onready var address = $MainMenu/MarginContainer/VBoxContainer/AddressEntry

const PORT  = 9999
var enet_peer = ENetMultiplayerPeer.new()

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_host_pressed():
	enet_peer.create_server(PORT)
	multiplayer.multiplayer_peer = enet_peer
	emit_signal("hosted")


func _on_join_pressed():
	enet_peer.create_client("localhost", PORT)
	multiplayer.multiplayer_peer = enet_peer
	emit_signal("joined")


func _on_single_player_pressed():
	emit_signal("single_player_started")
