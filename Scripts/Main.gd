extends Control

# Declare member variables here. Examples:
var last_scene_name = null
# var b = "text"

# Called when the node enters the scene tree for the first time.
func _ready():
	_load_scene("res://Scenes/title/title.tscn", "title")
	last_scene_name = "title"

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func _load_scene(scene_path, node_name):
	print(last_scene_name)
	if last_scene_name:
		self.get_tree().get_root().find_node(last_scene_name, true, false).free()
		print("freeing...")
	var scene = load(scene_path)
	var scene_instance = scene.instance()
	scene_instance.set_name(node_name)
	add_child(scene_instance)
	print("added loaded scene!")

func _on_transition(scene_path, node_name):
	# Can't directly call because we can't free until the signal stops emitting and calling
	call_deferred("_load_scene", scene_path, node_name)