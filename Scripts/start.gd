extends CanvasLayer

signal hosted
signal single_player_started
signal joined

@onready var mainMenu = $MainMenu
@onready var address = $MainMenu/MarginContainer/VBoxContainer/AddressEntry

const PORT  = 9999
var peer = WebSocketMultiplayerPeer.new()
func _ready():
	if "--server" in OS.get_cmdline_args():
		print ("Started server")
		call_deferred('_on_host_pressed')
	elif "--client" in OS.get_cmdline_args():
		print ("Started client")
		call_deferred('_on_join_pressed')
		
	print ("Menu started")

var count = 0
func _process(_delta):
	peer.poll()
	if (multiplayer.is_server()): return
	count  = (count + 1) % 120
	if count == 0: 
		print ("Start.tscn: process:", peer.get_connection_status())
	
func _on_host_pressed():
	if "--server" in OS.get_cmdline_args():
		var server_certs = load("res://assets/keys/fullchain.crt")
		var server_key = load("res://assets/keys/pubkey.key")
		var server_tls_options = TLSOptions.server(server_key, server_certs)
		print ("Server ssl activated")
		peer.create_server(PORT, "*", server_tls_options)
	else:
		peer.create_server(PORT)
	if peer.get_connection_status() == MultiplayerPeer.CONNECTION_DISCONNECTED:
		push_error("Failed to host at port:", PORT)
		return

	multiplayer.multiplayer_peer = peer
	print (peer)
	print (peer.get_connection_status())
	emit_signal("hosted")


func _on_join_pressed():
	var uri = "ws://localhost"
	#var uri = "wss://gobaan.com"
	print ("connecting to uri ", uri)
	peer.create_client(uri + ":" + str(PORT))
	if peer.get_connection_status() == MultiplayerPeer.CONNECTION_DISCONNECTED:
		push_error("Failed to host at ip: ", uri, ":", PORT)
		return
	print (peer.get_connection_status(), "-", MultiplayerPeer.CONNECTION_CONNECTING)
	multiplayer.multiplayer_peer = peer

	emit_signal("joined")


func _on_single_player_pressed():
	emit_signal("single_player_started")


func _notification(what):
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		print ("closing server")
		if peer.get_connection_status() != MultiplayerPeer.CONNECTION_DISCONNECTED:
			peer.close()
		get_tree().quit()
