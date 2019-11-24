extends Control
var nextScene
var xtransitionPanel:CanvasLayer
var curtains:AnimationPlayer

export(PackedScene) var scene_start

func _ready():
	self.xtransitionPanel = self.find_node("TransitionPanel")
	self.curtains = self.find_node("CurtainsAnimationPlayer")
	self.curtains.connect("animation_finished", self, "_on_animation_complete")
	self.nextScene = scene_start
	_load_scene(self.nextScene)
	#_load_scene()

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

#TODO: var for what kind of node to look for (pause, script, level)

func _transition_animation(enter_transition:bool):
	if enter_transition:
		self.xtransitionPanel.set_layer(2)
		self.curtains.play("Open")
	else:
		self.xtransitionPanel.set_layer(2)
		self.curtains.play("Close")
	#self.xtransitionPanel.set_layer(0)

func _on_animation_complete(anim_name:String):
	self.xtransitionPanel.set_layer(0)
	if anim_name == "Open":
		pass
	else:
		#call_deferred("_unload_scene")
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
		scene.free()

func _load_scene(scene_path):
	if not( scene_path is PackedScene):
		scene_path = load(scene_path)
	var scene_instance = scene_path.instance()
	self.find_node("LoadingLayer").add_child(scene_instance)
	print("added loaded scene!", scene_path)
	#self._transition_animation(false)

func _on_transition(scene_path):
	# Can't directly call because we can't free until the signal stops emitting and calling
	self._transition_animation(false)
	self.nextScene = scene_path