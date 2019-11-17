extends Particles2D

# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var count = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if count == 200:
		set_emitting(true)
	if count == 290:
		$Shaker.shake(1.2,15,8)	#Shake screen
		count = 0
	count += 1

