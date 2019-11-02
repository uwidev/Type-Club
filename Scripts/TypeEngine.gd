extends LineEdit

# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var list = ["Bob", "Gill", "Gary"]
signal correctInput
signal wrongInput

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func _unhandled_input(event): #LineEdit must have mouse_filter set to 'ignore' in order to prevent mouse input
	if event is InputEventKey:
		if event.scancode == KEY_Q:
			self.set_focus_mode(2) #Allow Text box to focused
			self.grab_focus() #Focus onto textbox
		elif event.scancode == KEY_ESCAPE:
			self.set_focus_mode(0) #prevents textbox from being focused


func _on_LineEdit_text_entered(new_text):
	self.clear()
	for i in list:
		if new_text == i:
			list.erase(new_text) #Deletes the Entry
			emit_signal("correctInput")
			return
	print("Wrong Word")
	emit_signal("wrongInput")
