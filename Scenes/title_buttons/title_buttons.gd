extends VBoxContainer

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

onready var buttons = get_children()
var selected

# Called when the node enters the scene tree for the first time.
func _ready():
	buttons[0].grab_focus()
	pass # Replace with function body.
	
func _input(event):
	if accepted_input(event):
		selected = false
		for child in buttons:
			if child.has_focus():
				selected = true
				print(child.get_focus_previous())
				break
			
			if !selected:
				buttons[0].grab_focus()
				print()

func accepted_input(event):
	if event.is_action_pressed("ui_up") or \
		event.is_action_pressed("ui_down") or \
		event.is_action_pressed("ui_left") or \
		event.is_action_pressed("ui_right") or \
		event.is_action_pressed("ui_focus_next") or \
		event.is_action_pressed("ui_focus_prev"):
		
		return true
	return false

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
