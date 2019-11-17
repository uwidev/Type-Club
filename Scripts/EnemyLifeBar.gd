extends TextureProgress

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

# Called when the node enters the scene tree for the first time.
func _ready():
	self.max_value = get_parent().get_parent().lifeList
	self.value = self.max_value
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
	
func OnDamageTaken(amount): #Signals connected to Enemy Life
	self.value -= amount
	
