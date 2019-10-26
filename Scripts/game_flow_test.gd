extends Node

signal wrong_key
signal completed_word

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

# Called when the node enters the scene tree for the first time.
func _ready():
	set_process_input(true)
	print("AAAAAAAAAAAAAA")

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func _input(ev):
	if ev.scencode == KEY_Q:
		print("WRONG MOVE SEND")
		emit_signal("wrong_key")

func _on_wrong_key():
	print("WRONG MOVE")

# ideas: 
# - signals from typing engine trigger here.
# - this flow calls a loop onto typing engine to start and listen. 
# When a relevant event happens, typing engine calls something appropriate here.