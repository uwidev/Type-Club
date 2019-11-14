extends Label

func _curry_tween_label(offset):
	material.set_shader_param('offset', offset[1])