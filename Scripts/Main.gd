extends Control
var nextScene
var xtransitionPanel:CanvasLayer
var curtains:AnimationPlayer

signal retry
signal main_menu

export(PackedScene) var scene_start

func _ready():
	self.xtransitionPanel = self.find_node("TransitionPanel")
	self.curtains = self.find_node("CurtainsAnimationPlayer")
	self.curtains.connect("animation_finished", self, "_on_animation_complete")
	self.nextScene = scene_start
	var scene:Node = _load_scene(self.nextScene)

func _transition_animation(enter_transition:bool):
	var colorRect:ColorRect = self.xtransitionPanel.find_node("ColorRect", true, true)
	colorRect.modulate = Color(1, 1, 1)#white
	if enter_transition:
		self.xtransitionPanel.set_layer(2)
		self.curtains.play("Open")
	else:
		self.xtransitionPanel.set_layer(2)
		self.curtains.play("Close")
	#self.xtransitionPanel.set_layer(0)

func show_game_over():
	var colorRect:ColorRect = self.xtransitionPanel.find_node("ColorRect", true, true)
	colorRect.modulate = Color(0, 0, 0)#black
	self.xtransitionPanel.set_layer(2)
	self.curtains.play("Close")
	var death_screen:Node = self._load_scene("res://components/game_over/game_over.tscn")
	_connect_death_screen_buttons(death_screen)
	
func _connect_death_screen_buttons(death_screen:Node):
	var retry_button:BaseButton = death_screen.find_node("Retry", true, false)
	retry_button.connect("pressed", self, "emit_retry_signal")
	var menu_button:BaseButton = death_screen.find_node("Main Menu", true, false)
	retry_button.connect("pressed", self, "emit_menu_signal")

func emit_retry_signal():
	emit_signal("retry")

func emit_menu_signal():
	emit_signal("main_menu")

func _on_animation_complete(anim_name:String):
	self.xtransitionPanel.set_layer(0)
	if anim_name == "Open":
		pass
	else:
		_unload_scene()
		_load_scene(self.nextScene)
		_transition_animation(true)

func _unload_scene():
	var del_list = self.find_node("LoadingLayer").get_children()
	for scene in del_list:
		# free most recent child, which should be the latest appended to open_scenes
		# print("freeing...", scene, self.get_child(self.get_child_count()-1))
		#self.get_child(self.get_child_count()-1).free()
		#open_scenes.remove(scene)
		print("freeing...", scene)
		scene.queue_free()

func _load_scene(scene_path):
	if not(scene_path is PackedScene):
		scene_path = load(scene_path)
	var scene_instance:Node = scene_path.instance()
	self.find_node("LoadingLayer").add_child(scene_instance)
	print("added loaded scene!", scene_path)
	#self._transition_animation(false)
	return scene_instance

func _on_transition(scene_path):
	# Can't directly call because we can't free until the signal stops emitting and calling
	self._transition_animation(false)
	self.nextScene = scene_path
#	_unload_scene()
#	_load_scene(scene_path)