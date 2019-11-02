extends Sprite

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

var can_i_move = true

# Called when the node enters the scene tree for the first time.
func _ready():

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if can_i_move == true:
		translate(Vector2(1, 0))









