extends Control

enum {PREVIOUS = 1, NEXT = -1}

var debug_list = ['math', 'science', 'video games']

# Word Scroller holds a label_list which is a representation of Labels on a scroller
# Index 0 refers to center, while positve indices refer to next, negative incides
# 	refer to previous. It's width is expandable and will adjust accordingly.
#
# word_lists will contain the list of words

var wdict
var wlist
var label_list = []
var label_positions = []
var selected = RoundIndex.new() 		# Tied to wlist as an index
var assigner_round = RoundIndex.new()
var assigner_center = CenterRoundIndex.new()
var scroll_width
var half_width 							# Half of the total scroll width
var l_mat
var typing_label = RichTextLabel.new()
var particle_word_reference

# Debug
export(bool) var debug_list_of_words
export(bool) var transparency = true
export(bool) var focus_on_ready

# Must have references
export(Material) var label_material
export(GDScript) var label_tween

# Settings
export(float) var transparency_exponent = 1
export(int) var word_spacing = 20
export(int) var font_size = 20
export(int) var extend = 2		# Amount of words extending from center, one direction
export(float) var scroll_speed = 0.3
export(int, 'Linear', 'Sine', 'Quint', 'Quart', 'Quad', 'Expo', 'Elastic', 'Cubic', 'Circ', 'Bounce', 'Back') var scroll_type
export(int, 'Ease In', 'Ease Out', 'Ease In Out', 'Ease Out In (No Ease)') var ease_type
export(float) var hidden_fade_in_speed = 2
export(float) var hidden_fade_out_speed = 0.5

onready var tween = get_node("Tween")
onready var SE = get_node("SE")

signal word_selected
signal words_fully_visible
signal redrew
signal bad_first_key

# A class meant to have a value that loops once it hits the end of a normal array
class RoundIndex:
	var value setget set_value, get_value
	var _max_index setget set_max, get_max
	
	func _init():
		value = 0
		_max_index = 0
		
	func next():
		if value >= _max_index:
			value = 0
		else:
			value += 1
	
	func prev():
		if value == 0:
			value = _max_index
		else:
			value -= 1
		
	func set_value(v):
		if v < 0:
			value = 0
		else:
			value = v
	
	func get_value():
		return value
		
	func set_max(m):
		if m < 0:
			_max_index = 0
		else:
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
	particle_word_reference = get_tree().get_root().find_node('particle_viewport', true, false)
	typing_label.set_name('typing_label')
	add_child(typing_label)
	typing_label.set_visible(false)
	typing_label.set_scroll_active(false)
	
	
	if focus_on_ready:
		grab_focus() 
	
	# Creates specified number of labels, extend + 2 for queueing and animation
	scroll_width = extend * 2 + 2
	half_width = scroll_width/2
	for i in range(0, scroll_width + 1):
		label_list.append(_create_format_label())
		label_positions.append(0)
		
	# For debugging purposes
	if debug_list_of_words:
		wlist = debug_list
		selected.set_max(wlist.size()-1)
		_set_labels()
		_hidden_instant(true)
		#particle_word_reference._set_text(wlist[selected.get_value()])


func link_lists(d, w):
	wdict = d
	wlist = w
	
	_set_labels()
	_hidden_instant(true)
	particle_word_reference._set_text(wlist[selected.get_value()])


func on_end_typing(word):
	grab_focus()
	selected.set_max(wlist.size()-1)


# Creates label and adds it as a child to current node
func _create_format_label(): # -> returns a centercontainer with label child object
	var center
	var label
	center = CenterContainer.new()
	center.set_use_top_left(true)
	
	label = Label.new()
	label.set_name('label')
	
	if transparency:
		label.set_material(label_material.duplicate())
		label.set_script(label_tween)
	
	center.add_child(label)
	add_child(center)
	return center


# Called when you want to advance the list
func _next():
	selected.next()
	_animate_and_update(NEXT)


# Called when you want to backtrack the list
func _previous():
	selected.prev()
	_animate_and_update(PREVIOUS)


# Initializes the label's text and position. with 0 index of word_list being the center
func _set_labels():
	var label
	var index
	var min_spacing = label_list.front().get_node('label').get_size().y
	
	assigner_round.set_max(wlist.size()-1)
	assigner_round.set_offset(-half_width)

	index = assigner_round.get_value()
	for i in range(-half_width, half_width+1):
		label = label_list[i].get_node('label')
		
		if transparency:
			l_mat = label.material
			l_mat.set_shader_param('extend', half_width)
			l_mat.set_shader_param('height', min_spacing + word_spacing)
			l_mat.set_shader_param('offset', (min_spacing + word_spacing) * i)
			l_mat.set_shader_param('exponent', transparency_exponent)
		
		label_positions[i] = Vector2(0.0, (min_spacing + word_spacing) * i)
		label_list[i].set_position(label_positions[i])
		
		label_list[i].get_node('label').set_text(wlist[index])
	
		assigner_round.next()
		index = assigner_round.get_value()


# NOT WORKING, GET WORKING
func _hidden(hiding:bool):
	tween.remove_all()
	
	#print('going to hide: ', hiding)
	var label
	var l_mat
	var min_spacing = label_list.front().get_node('label').get_size().y
	
	for i in range(-half_width, half_width+1):
		label = label_list[i].get_node('label')
		l_mat = label.material
		#print(label_positions[i])
		if hiding:
			#print('>>>> GOING TO HIDE')
			if i < 0:
				tween.interpolate_method(label_list[i].get_node('label'), '_curry_tween_hidden_label', label_positions[i][1], (min_spacing + word_spacing) * -half_width, hidden_fade_out_speed,  Tween.TRANS_LINEAR, Tween.EASE_IN)
			elif i >= 0:
				tween.interpolate_method(label_list[i].get_node('label'), '_curry_tween_hidden_label', label_positions[i][1], (min_spacing + word_spacing) * half_width, hidden_fade_out_speed,  Tween.TRANS_LINEAR, Tween.EASE_IN)
		else:
			if i < 0:
				tween.interpolate_method(label_list[i].get_node('label'), '_curry_tween_hidden_label', (min_spacing + word_spacing) * -half_width, label_positions[i][1], hidden_fade_in_speed,  Tween.TRANS_LINEAR, Tween.EASE_IN)
			elif i >= 0:
				tween.interpolate_method(label_list[i].get_node('label'), '_curry_tween_hidden_label', (min_spacing + word_spacing) * half_width, label_positions[i][1], hidden_fade_in_speed,  Tween.TRANS_LINEAR, Tween.EASE_IN)
				
	#print('started tween')
	tween.start()
	

func _hidden_instant(hiding:bool):
	var label
	var l_mat
	var min_spacing = label_list.front().get_node('label').get_size().y
	
	for i in range(-half_width, half_width+1):
		label = label_list[i].get_node('label')
		l_mat = label.material
		#print(label_positions[i])
		if hiding:
			label_list[i].get_node('label')._curry_tween_hidden_label((min_spacing + word_spacing) * (half_width+1))
		else:
			label_list[i].get_node('label')._curry_tween_hidden_label(label_positions[i][1])
				
	#print('instant hide: ', hiding)


func _update_labels():
	#print('current wlist: ', wlist)
	selected.set_max(wlist.size()-1)
	if wlist.empty():
		for i in range(-half_width, half_width+1):
			label_list[i].get_node('label').set_text('')
		return

	var label
	var index
	
	assigner_round.set_value(selected.get_value())
	assigner_round.set_max(wlist.size()-1)
	assigner_round.set_offset(-half_width)

	index = assigner_round.get_value()
	for i in range(-half_width, half_width+1):
		label_list[i].get_node('label').set_text(wlist[index])
	
		assigner_round.next()
		index = assigner_round.get_value()
	
	particle_word_reference._set_text(wlist[selected.get_value()])


func _animate_and_update(mode):	
	# Setup
	var interval
	var a_value
	tween.remove_all()
	
	# Teleport the clipping label to the top/bottom
	# Only select the labels that need to be moved
	if mode == NEXT: # Moves up
		if transparency:
			label_list[-half_width].get_node('label')._curry_tween_label(label_positions[half_width])
		label_list[-half_width].set_position(label_positions[half_width])
		interval = range(-half_width+1, half_width+1)
	elif mode == PREVIOUS: # Moves down
		if transparency:
			label_list[half_width].get_node('label')._curry_tween_label(label_positions[-half_width])
			
		label_list[half_width].set_position(label_positions[-half_width])
		interval = range(-half_width, half_width+1-1)
	
	assigner_round.set_value(interval[0])
	assigner_round.set_max(half_width)
	a_value = assigner_round.get_value()
	# Actual animating part
	for i in interval:
		# Tween by calling the node's function which sets parameters for the shader,
		# other parameters supplied to the set function are already set.
		if transparency:	
			tween.interpolate_method(label_list[i].get_node('label'), '_curry_tween_label', label_positions[i], label_positions[i+mode], scroll_speed,  scroll_type, ease_type)
		
		tween.interpolate_property(label_list[i], 'rect_position', label_positions[i], label_positions[i+mode], scroll_speed,  scroll_type, ease_type)
		
		assigner_round.next()
		a_value = assigner_round.get_value()
	
	tween.start()

	# Update the label_list array such that it holds inegrity
	if mode == NEXT:
		label_list.push_back(label_list.pop_front())
		label_list[half_width].get_node('label').set_text(wlist[selected.calc_offset(half_width)])
	elif mode == PREVIOUS:
		label_list.push_front(label_list.pop_back())
		label_list[-half_width].get_node('label').set_text(wlist[selected.calc_offset(-half_width)])
	
	if not debug_list_of_words:
		particle_word_reference._set_text(wlist[selected.get_value()])


func _input(event):
	if has_focus() and event is InputEventKey:
		if event.is_pressed() and not event.is_echo() and not wlist.empty():
			if event.get_scancode() == KEY_DOWN:	# Key up
				SE.play_scroll()
				_next()
			elif event.get_scancode() == KEY_UP:	# Key down
				SE.play_scroll()
				_previous()
			elif char(event.get_unicode()) == wlist[selected.get_value()].left(1):
				label_list[0].set_visible(false)
				typing_label.set_text(wlist[selected.get_value()])
				typing_label.set_custom_minimum_size(label_list[0].get_node('label').get_size())
				typing_label.set_position(label_list[0].get_node('label').get_position())
				typing_label.set_visible(true)
				
				particle_word_reference._set_text(wlist[selected.get_value()])
				
				emit_signal('word_selected', wlist[selected.get_value()], 
					typing_label.get_global_position())
			else:
				emit_signal("bad_first_key")
			accept_event()
		elif wlist.empty():
			accept_event()


func _on_request_scroller():
	typing_label.set_visible(false)
	label_list[0].set_visible(true)
	grab_focus()


func _on_end_cycle():
	#print('on_end_cycle')
	typing_label.set_visible(false)
	label_list[0].set_visible(true)
	grab_focus()
	selected.set_max(wlist.size()-1)
	
	wlist.shuffle()
	_update_labels()


func _on_prepare_stage():
	#print('preparing stage')
	typing_label.set_visible(false)
	label_list[0].set_visible(true)
	_update_labels()
	_hidden(false)
	#print('waiting until tween complete')
	yield(tween, "tween_all_completed")
	#print('tween visible complete')
	
	emit_signal('words_fully_visible')
	

func _on_stage_ready():
	#print('stage ready!')
	grab_focus()

func _on_scroller_redraw():
	emit_signal('redrew', typing_label.get_global_position())


func stage_clear_hide():
	label_list[0].set_visible(true)
	typing_label.set_visible(false)
	_hidden(true)


func _on_Tween_tween_all_completed():
	#print('>>> all tween completed')
	pass
