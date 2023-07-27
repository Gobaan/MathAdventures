extends Node

func _enter_tree():
	set_multiplayer_authority(str(get_parent().get_parent().name).to_int())
	
