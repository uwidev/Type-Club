extends Control

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

signal level_start
export(String) var WordList

# Called when the node enters the scene tree for the first time.
func _ready():
	emit_signal("level_start", WordList)
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
