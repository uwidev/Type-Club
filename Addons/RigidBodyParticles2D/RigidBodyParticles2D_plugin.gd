tool
extends EditorPlugin

func _enter_tree():
	# When this plugin node enters tree, add the custom type

	add_custom_type("RigidBodyParticles2D","Particles2D",preload("res://addons/RigidBodyParticles2D/RigidBodyParticles2D.gd"),
	preload("res://addons/GodotTIE/GodotTIE_icon.png"))

func _exit_tree():
	# When the plugin node exits the tree, remove the custom type

	remove_custom_type("RigidBodyParticles2D")




	
