extends Node

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

export(Array, int) var lifeList #List of ints representing health for each state, 0 reps stage 1
var currentLife = 0
signal enemy_dead

# Called when the node enters the scene tree for the first time.
func _ready():
	currentLife = lifeList.pop_front()
	pass # Replace with function body.
	
func offsetLife(amount):
	currentLife -= amount;
	if currentLife <= 0:
		emit_signal("enemy_dead")
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
