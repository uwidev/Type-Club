extends Node2D

# Declare member variables here. Examples:
# var a = 2
# var b = "text
"
var a = 0
# Called when the node enters the scene tree for the first time.
func _ready():
	print("Ready in GDscript")

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func called_on_timer_done():
	print("it's done!")
