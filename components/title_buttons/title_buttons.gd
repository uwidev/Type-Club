extends VBoxContainer

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

onready var buttons = get_children()
var selected

signal new_game
signal load_game
signal options
signal exit

# Called when the node enters the scene tree for the first time.
func _ready():
	pass


func _input(event):
	if event is InputEventKey:
		if event.pressed:
			if event.scancode == KEY_TAB:
				for button in buttons:
					if button.has_focus():
						return
				buttons[0].grab_focus()
				accept_event()


func _on_new_game_pressed():
	emit_signal('new_game')


func _on_load_game_pressed():
	emit_signal('load_game')


func _on_options_pressed():
	emit_signal('options')


func _on_exit_pressed():
	emit_signal('exit')
