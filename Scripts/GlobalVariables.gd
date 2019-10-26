extends Node
#Must be attached to a node (on the main scene)

# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var current_scene = null

# Called when the node enters the scene tree for the first time.
func _ready():
	var root = get_tree().get_root()
	#Gets the current scene cuz its the last child
	current_scene = root.get_child(root.get_child_count()-1)
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func switchScene(path):
	call_deferred("deferredSwitchScene",path)
	
func deferredSwitchScene(path):
	current_scene.free()
	
	var s = ResourceLoader.load(path)
	
	current_scene = s.instance()
	
	get_tree().get_root().add_child(current_scene)
	get_tree().set_current_scene(current_scene)
