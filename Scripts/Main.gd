extends Control

# Declare member variables here. Examples:
# var b = "text"

# Called when the node enters the scene tree for the first time.
func _ready():
	_load_scene("res://Scenes/title/title.tscn")

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

#TODO: var for what kind of node to look for (pause, script, level)

func _load_scene(scene_path, delete=true):
	# if the current open scenes should be deleted:
	if delete:
		for scene in self.get_children():
			# free most recent child, which should be the latest appended to open_scenes
			# print("freeing...", scene, self.get_child(self.get_child_count()-1))
			#self.get_child(self.get_child_count()-1).free()
			#open_scenes.remove(scene)
			print("freeing...", scene)
			scene.free()
	if not( scene_path is PackedScene):
		scene_path = load(scene_path)
	var scene_instance = scene_path.instance()
	add_child(scene_instance)
	print("added loaded scene!", scene_path)

func _on_transition(scene_path):
	# Can't directly call because we can't free until the signal stops emitting and calling
	call_deferred("_load_scene", scene_path)