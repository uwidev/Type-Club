extends Control

func _curry_tween_label(vect):
	#print('tween normal')
	material.set_shader_param('offset', vect[1])
	
func _curry_tween_hidden_label(val):
	#print('hidden tweening')
	material.set_shader_param('offset', val)