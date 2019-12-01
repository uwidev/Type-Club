extends "res://Scenes/LoadableScene.gd"

export(String) var menu_scene

func _on_return_to_menu_pressed():
	emit_signal('end_level', menu_scene)