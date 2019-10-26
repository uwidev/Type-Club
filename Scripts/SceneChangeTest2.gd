extends Sprite

# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var counter = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if counter > 200:
		get_tree().change_scene("res://Scenes/Annie_Scene_2.tscn")
	var moveRight = Vector2(1,0)
	translate(moveRight)
	counter += 1