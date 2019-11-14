extends Sprite

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

class Test:
	func keys():
		print('keys call')
		return [1, 2, 3]

# Called when the node enters the scene tree for the first time.
func _ready():
	var test = Test.new()
	for i in test.keys():
		print(i)

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
