extends Control

func _ready():
	var label = Label.new()
	#label.set_visible(false)
	add_child(label)
	label.set_name('test')
	get_node('test').connect('item_rect_changed', self, '_on_item_rect_changed')
	label.set_text('test')


func _input(event):
	if event is InputEventKey:
		if event.pressed:
			get_node('test').set_text("rentnwerjktlnwekljtnwekjltnkjwlernt")
			print('label: ', get_node('Label').get_size())
			print('rich: ', get_node('RichTextLabel').get_size())


func _on_item_rect_changed():
	print('signal: ', get_node('test').get_size())
