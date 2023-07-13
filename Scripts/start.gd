extends Control

signal host
@onready var mainMenu = $CanvasLayer/MainMenu
@onready var address = $CanvasLayer/MainMenu/MarginContainer/VBoxContainer/AddressEntry

const port = 99999
var enet_peer = ENetMultiplayerPeer.new()

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_host_pressed():
	enet_peer.create_server(port)
	multiplayer.multiplayer_peer = enet_peer
	emit_signal("host")


func _on_join_pressed():
	pass # Replace with function body.
