extends Node
#Must be attached to a node (on the main scene)

# Declare member variables here. Examples:
var current_scene = null
var scriptLine = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	pass
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func switchScene(path):
	call_deferred("deferredSwitchScene",path)
	
func deferredSwitchScene(path):
	var root = get_tree().get_root()
	#Gets the current scene cuz its the last child
	root.get_child(root.get_child_count()-1).free()
	
	var s = ResourceLoader.load(path)
	
	current_scene = s.instance()
	
	get_tree().get_root().add_child(current_scene)
	get_tree().set_current_scene(current_scene)
