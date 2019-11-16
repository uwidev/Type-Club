extends Control

# Declare member variables here. Examples:
var open_scenes = []
# var b = "text"

# Called when the node enters the scene tree for the first time.
func _ready():
	_load_scene("res://Scenes/title/title.tscn")

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func _load_scene(scene_path, delete=true):
	var node_name = scene_path
	print(open_scenes, node_name)
	# if the current open scenes should be deleted:
	if delete:
		for scene in open_scenes:
			#TODO: It hasn't come up yet, but the list traversal is bad. Need to reverse
			#to suit the "latest appended" model of finding children to free.
			#If no need for a list, just use a single var.
			# free most recent child, which should be the latest appended to open_scenes
			print("freeing...", scene, self.get_child(self.get_child_count()-1))
			self.get_child(self.get_child_count()-1).free()
			open_scenes.remove(scene)
			# Lower line is preserved as a comment
			# just in case we ever make a child that we can't access via the last index
			# self.find_node(scene, true, false).free()
	open_scenes.append(node_name)
	var scene_instance = load(scene_path).instance()
	scene_instance.set_name(node_name)
	add_child(scene_instance)
	print("added loaded scene!", node_name)

func _on_transition(scene_path, node_name):
	# Can't directly call because we can't free until the signal stops emitting and calling
	call_deferred("_load_scene", scene_path, node_name)