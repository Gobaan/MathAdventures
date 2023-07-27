extends Control

func _on_restart_pressed():
	get_tree().reload_current_scene() 
	
@rpc
func show_gameover():
	visible =  true
