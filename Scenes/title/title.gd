extends Control

signal transition
# Declare member variables here. Examples:
# var a = 2
# var b = "text"

# Called when the node enters the scene tree for the first time.
func _ready():
	var button_list = {
		"new_game": "_on_new_game_press",
		"load_game": "_on_load_game_press",
		"options": "_on_options_press",
		"exit": "_on_exit_press",
	}
	var root = self.get_tree().get_root()
	for button in button_list:
		root.find_node(button, true, false).connect("button_down", self, button_list[button])
	self.connect("transition", root.find_node("Main", true, false), "_on_transition")

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func _on_new_game_press():
	emit_signal("transition", "res://Scenes/Annie_Scene.tscn", "annie")

func _on_load_game_press():	
	print("Loading game...")

func _on_options_press():
	print("op")

func _on_exit_press():
	get_tree().quit()