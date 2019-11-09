extends Control

# Declare member variables here. Examples:
signal transition

# Called when the node enters the scene tree for the first time.
func _ready():
	var root = self.get_tree().get_root()
	self.connect("transition", root.find_node("Main", true, false), "_on_transition")

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass