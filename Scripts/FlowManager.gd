extends Node

# Declare member variables here. Examples:
signal completed_word
var counter = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	self.connect("completed_word", self, "_on_completed_word")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	counter = (counter + 1) % 20
	if not counter:
		emit_signal("completed_word", "")

func _on_completed_word(word):
	var tree = self.get_tree()
	var root = tree.get_root()
	#print(root.get_children()[0].get_children()[1].get_children())
	var control = root.find_node("Control", true, false)
	print("Control__:", control)
	if control:
		var life = control.find_node("TextureRect") # control.find_node("Life")
		print("life___", life)
		life.find_node("Right").value -= 1
		life.find_node("Left").value -= 1
		print(life.find_node("Left"))
	else:
		print("not found")
	print()