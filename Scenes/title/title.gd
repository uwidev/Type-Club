extends "res://Scenes/LoadableScene.gd"

export(PackedScene) var next_scene

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

func _on_new_game_press():
	emit_signal("end_level", next_scene)

func _on_load_game_press():	
	print("Loading game...")

func _on_options_press():
	print("op")

func _on_exit_press():
	get_tree().quit()