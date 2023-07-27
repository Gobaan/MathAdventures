extends Control

@onready var score = $Score:
	set (value):
		score.text = "Score: " + str(value)
		
# Called when the node enters the scene tree for the first time.
@onready var lives_ui = $Lives
var uilife_scene = preload("res://Scenes/ui_life.tscn")

func _enter_tree():
	set_multiplayer_authority(str(get_parent().name).to_int())


func init_lives(amount):
	if !is_multiplayer_authority() or !lives_ui: return
	show()
	for ui_life in lives_ui.get_children():
		ui_life.queue_free()
		
	for i in amount:
		var ui_life = uilife_scene.instantiate()
		lives_ui.add_child(ui_life)

		
		
