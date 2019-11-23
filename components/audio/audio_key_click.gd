extends AudioStreamPlayer

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

var rng = RandomNumberGenerator.new()
var scancode

export(bool) var enabled
export(Array, AudioStream) var key_down_a
export(Array, AudioStream) var key_up_a

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.
	
func _input(event):
	if enabled:
		if event is InputEventKey and key_accepted(event) and not event.is_echo():
			if not event.is_pressed():
				set_stream(key_down_a[rng.randi_range(0, key_down_a.size()-1)])
				play()
			else:
				set_stream(key_up_a[rng.randi_range(0, key_down_a.size()-1)])
				play()
		
func key_accepted(event):
	scancode = event.get_scancode()
	if scancode >= KEY_A and scancode <= KEY_Z  or scancode == KEY_SPACE or \
	scancode == KEY_ENTER or scancode == KEY_BACKSPACE:
		return true
	return false
	
func set_enabled(boo):
	if boo is bool:
		enabled = boo

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
