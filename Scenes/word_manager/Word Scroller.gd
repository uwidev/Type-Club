extends Control

enum {PREVIOUS = 1, NEXT = -1}

# Word Scroller holds a label_list which is a representation of Labels on a scroller
# Index 0 refers to center, while positve indices refer to next, negative incides
# 	refer to previous. It's width is expandable and will adjust accordingly.
#
# word_lists will contain the list of words

#var words_list = ['0', '1', '2']		# Preset list for debugging
var words_dict = {}
var words_list = []
var label_list = []
var label_positions = []
var label								# Temp var to hold labels
var center
var min_spacing
var selected = RoundIndex.new() 		# Tied to words_list as an index
var assigner = CenterRoundIndex.new() 	# Tied to label_list as an index
var scroll_width
var half_width 							# Half of the total scroll width
var l_mat

export(NodePath) var referenced_node
export(String) var dictionary_name
export(String) var signal_end_typing
export(bool) var focus_on_ready
export(Theme) var font_theme			# Takes in a theme so it applies to all labels
export(int) var word_spacing = 20
export(int) var font_size = 20
export(int) var extend = 2		# Amount of words extending from center, one direction
export(float) var scroll_speed = 0.3
export(int, 'Linear', 'Sine', 'Quint', 'Quart', 'Quad', 'Expo', 'Elastic', 'Cubic', 'Circ', 'Bounce', 'Back') var scroll_type
export(int, 'Ease In', 'Ease Out', 'Ease In Out', 'Ease Out In (No Ease)') var ease_type
export(Material) var label_material
export(Resource) var label_tween

onready var tween = get_node("Tween")



# A class meant to have a value that loops once it hits the end of a normal array
class RoundIndex:
	var value setget set_value, get_value
	var _max_index setget set_max, get_max
	
	func _init():
		value = 0
		_max_index = 0
		
	func next():
		value += 1
		if value > _max_index:
			value = 0
	
	func prev():
		value -= 1
		if value < 0:
			value = _max_index
			
	func set_value(v):
		value = v
	
	func get_value():
		return value
		
	func set_max(m):
		_max_index = m
		if value > _max_index:
			value = 0
	
	func get_max():
		return _max_index
	
	# next()/prev() v amount of times	
	func set_offset(v):
		if v < 0:
			for i in range(0, v, -1):
				prev()
		else:
			for i in range(0, v):
				next()
	
	# Calculates an immediate offset, used for reassigning labels for loop
	func calc_offset(val):
		if val == 0:
			return value
		
		var v = val
		if val > 0:
			while value + v > _max_index:
				v -= _max_index + 1
			return value + v
		elif val < 0:
			while value + v < 0:
				v += _max_index + 1
			return value + v


# Extends from RoundIndex, but instead modeled after Word Scroller,
# it's center at 0 and max index being size/2 and min -size/2
class CenterRoundIndex:
	extends RoundIndex
	func next():
		value += 1
		if value > _max_index:
			value = -_max_index


func _ready():
	# Connect and setup from game loop control script
	var ref_node = get_node(referenced_node)
	# ref_node.connect(signal_end_typing, self, "_on_end_typing")			# Uncomment so can connect
	words_dict = ref_node.get(dictionary_name)
	words_list = words_dict.keys()
	
	if focus_on_ready:
		grab_focus() # For debugging purposes
	
	# Assigns Theme
	font_theme.get_default_font().set_size(font_size)
	
	# Creates specified number of labels, extend + 2 for queueing and animation
	scroll_width = extend * 2 + 2
	half_width = scroll_width/2
	for i in range(-1, scroll_width):
		label_list.append( create_format_label() )
		label_positions.append(0)

	min_spacing = label_list.front().get_node('label').get_size().y
	
	# Initializes max index for selected
	selected.set_max(words_list.size()-1)
	
	_set_labels()


func _on_end_typing():
	grab_focus()
	selected.set_max(words_list.size()-1)
	words_list = words_dict.keys()


# Creates label and adds it as a child to current node
func create_format_label(): # -> returns a centercontainer with label child object
	center = CenterContainer.new()
	center.set_use_top_left(true)
	
	label = Label.new()
	label.set_name('label')
	label.set_theme(font_theme)
	label.set_material(label_material.duplicate())
	label.set_script(label_tween)
	
	center.add_child(label)
	add_child(center)
	return center


# Called when you want to advance the list
func next():
	selected.next()
	#print(selected.get_value())
	_animate_and_update(NEXT)


# Called when you want to backtrack the list
func previous():
	selected.prev()
	_animate_and_update(PREVIOUS)


# Initializes the label's text and position. with 0 index of word_list being the center
func _set_labels():
	var helper = RoundIndex.new()
	var index
	helper.set_max(words_list.size()-1)
	helper.set_offset(-half_width)
	
	index = helper.get_value()
	for i in range(-half_width, half_width+1):
		label = label_list[i].get_node('label')
		l_mat = label.material
		
		l_mat.set_shader_param('extend', half_width)
		l_mat.set_shader_param('height', min_spacing + word_spacing)
		l_mat.set_shader_param('offset', (min_spacing + word_spacing) * i)
		
		label_positions[i] = Vector2(0.0, l_mat.get_shader_param('offset'))
#		label_positions[i] = Vector2(0.0, (min_spacing + word_spacing) * i)
		print(l_mat.get_shader_param('offset'), " | ", l_mat.get_shader_param('height'), " ", l_mat.get_shader_param('extend'))
		label_list[i].set_position(label_positions[i])
		
		label_list[i].get_node('label').set_text(words_list[index])
	
		helper.next()
		index = helper.get_value()
	pass


func _animate_and_update(mode):	
	# Setup
	var interval
	var a_value
	if tween.is_active():
		tween.stop_all()
	
	# Teleport the clipping label to the top/bottom
	# Only select the labels that need to be moved
	if mode == NEXT: # Moves up
		label_list[-half_width].set_position(label_positions[half_width])
		label_list[-half_width].get_node('label')._curry_tween_label(label_positions[half_width])
		interval = range(-half_width+1, half_width+1)
	elif mode == PREVIOUS: # Moves down
		label_list[half_width].set_position(label_positions[-half_width])
		label_list[half_width].get_node('label')._curry_tween_label(label_positions[-half_width])
		interval = range(-half_width, half_width+1-1)
	
	assigner.set_value(interval[0])
	assigner.set_max(half_width)
	a_value = assigner.get_value()
	# Actual animating part
	for i in interval:
		tween.interpolate_property(label_list[i], 'rect_position', label_positions[i], label_positions[i+mode], scroll_speed,  scroll_type, ease_type)
		tween.interpolate_method(label_list[i].get_node('label'), '_curry_tween_label', label_positions[i], label_positions[i+mode], scroll_speed,  scroll_type, ease_type)
		assigner.next()
		
		a_value = assigner.get_value()
	
	tween.start()

	# Update the label_list array such that it holds inegrity
	if mode == NEXT:
		label = label_list.pop_front()
		label_list.push_back(label)

		label_list[half_width].get_node('label').set_text(words_list[selected.calc_offset(2)])
	elif mode == PREVIOUS:
		label = label_list.pop_back()
		label_list.push_front(label)

		label_list[-half_width].get_node('label').set_text(words_list[selected.calc_offset(-2)])


func _input(event):
	if has_focus():
		if event.is_pressed() and not event.is_echo():
			if event.is_action_pressed("ui_up"):
				previous()
			if event.is_action_pressed("ui_down"):
				next()