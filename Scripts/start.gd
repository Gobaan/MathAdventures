extends CanvasLayer

signal hosted
signal single_player_started
signal joined

@onready var mainMenu = $MainMenu
@onready var address = $MainMenu/MarginContainer/VBoxContainer/AddressEntry

const PORT  = 9999
var enet_peer = ENetMultiplayerPeer.new()
func _ready():
	if "--server" in OS.get_cmdline_args():
		print ("Started server")
		call_deferred('_on_host_pressed')
	elif "--client" in OS.get_cmdline_args():
		print ("Started client")
		call_deferred('_on_join_pressed')
		
	print ("Menu started")
	
func _on_host_pressed():
	enet_peer.create_server(PORT)
	if enet_peer.get_connection_status() == MultiplayerPeer.CONNECTION_DISCONNECTED:
		push_error("Failed to host at port:", PORT)
		return
	multiplayer.multiplayer_peer = enet_peer
	print (enet_peer)
	emit_signal("hosted")


func _on_join_pressed():
	var uri = "gobaan.com"
	enet_peer.create_client(uri, PORT)
	if enet_peer.get_connection_status() == MultiplayerPeer.CONNECTION_DISCONNECTED:
		push_error("Failed to host at ip: ", uri, ":", PORT)
		return
	multiplayer.multiplayer_peer = enet_peer
	emit_signal("joined")


func _on_single_player_pressed():
	emit_signal("single_player_started")


func _exit_tree():
	print ("closing server")
	if enet_peer.get_connection_status() != MultiplayerPeer.CONNECTION_DISCONNECTED:
		enet_peer.close()
