extends Control

@onready var score = $Score:
	set (value):
		score.text = "Score: " + str(value)
		
# Called when the node enters the scene tree for the first time.
@onready var lives = $Lives
var uilife_scene = preload("res://Scenes/ui_life.tscn")
func init_lives(amount):
	for ui_life in lives.get_children():
		ui_life.queue_free()
		
	for i in amount:
		var ui_life = uilife_scene.instantiate()
		lives.add_child(ui_life)
