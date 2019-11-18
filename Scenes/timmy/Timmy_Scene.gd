extends Control

func _ready():
	yield($Button, 'pressed')
	print('you just pressed!')
