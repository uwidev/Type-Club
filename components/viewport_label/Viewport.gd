extends Viewport

onready var label = $Camera2D/current_word

func _set_text(text):
	#print('setting text: ', text)
	label.set_size(Vector2(0, 0))
	label.set_text(text)
	set_size(label.get_size() + Vector2(50, 0))