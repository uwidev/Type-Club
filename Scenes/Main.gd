extends Node2D

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

# Called when the node enters the scene tree for the first time.
func _ready():
	_load_scene("res://Scenes/title/title.tscn", "title")
	var root = self.get_tree().get_root()
	#print(root.get_children()[0].get_children()[1].get_children())
	var button_list = {
		"new_game": "_on_new_game_press",
		"load_game": "_on_load_game_press",
		"options": "_on_options_press",
		"exit": "_on_exit_press",
	}
	for button in button_list:
		root.find_node(button, true, false).connect("button_down", self, button_list[button])

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func _load_scene(scene_path, node_name):
	var scene = load(scene_path)
	var scene_instance = scene.instance()
	scene_instance.set_name(node_name)
	add_child(scene_instance)
	
func _on_new_game_press():
	self.get_tree().get_root().find_node("title", true, false).free()
	self._load_scene("res://Scenes/Annie_Scene.tscn", "annie")
	print("loaded scene!")

func _on_load_game_press():
	print("Loading game...")

func _on_options_press():
	print("op")

func _on_exit_press():
	get_tree().quit()
