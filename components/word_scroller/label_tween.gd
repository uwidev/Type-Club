extends Control

func _curry_tween_label(offset):
	#print('tween normal')
	material.set_shader_param('offset', offset[1])
	
func _curry_tween_hidden_label(offset):
	#print('hidden tweening')
	material.set_shader_param('offset', offset)