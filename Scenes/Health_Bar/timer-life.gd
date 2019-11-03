extends Control

var total_time
var minutes
var seconds
var miliseconds

export(int) var MaxTimeLife = 20
export(bool) var Autostart

onready var label_left = get_node("Timer/left")
onready var label_right = get_node("Timer/right")
onready var timer = get_node("Timer/Timer")
onready var life_bar = get_node("Left")

func _ready():
	get_node('Left').share(get_node('Right'))
	timer.set_wait_time(MaxTimeLife)
	life_bar.set_value(100)

func _process(delta):
	# Autostart
	if Autostart and timer.is_stopped():
		timer.start()
		Autostart = false
	
	# Calculations
	total_time = timer.get_time_left()
	minutes = int(total_time/60)
	seconds = int(total_time-minutes*60)
	miliseconds = int((total_time-int(total_time))*100)
	
	# Label Assignment
	if not timer.is_stopped():
		if not minutes:
			label_left.set_text(str("%02d" % seconds))
			label_right.set_text(str("%02d" % miliseconds))
		else:
			label_left.set_text(str("%02d" % minutes))
			label_right.set_text(str("%02d" % seconds))
		
	# Modify Life Bar
	life_bar.set_value(timer.get_time_left()/MaxTimeLife*life_bar.get_max())
	
	# Testing/Debugging purposes
	if Input.is_action_just_pressed("ui_right"):
		if not timer.is_paused():
			paused(true)
		else:
			paused(false)

	if Input.is_action_just_pressed("ui_left"):
		offset_life_percent(.2)
	
# Given an number, offset life by that much
func offset_life(time):
	if time is int or time is float:
		timer.set_wait_time(timer.get_time_left()+time)
		timer.start()
		life_bar.set_value(timer.get_time_left()/MaxTimeLife*life_bar.get_max())

# Given a decimal, offset life by that much
func offset_life_percent(percent):
	if percent is int or percent is float:
		timer.set_wait_time(min(timer.get_time_left()*(1+percent), MaxTimeLife))
		timer.start()
		life_bar.set_value(timer.get_time_left()/MaxTimeLife*life_bar.get_max())
	
# Accepts boolean to pause or unpause
func paused(boo):
	if boo is bool:
		timer.set_paused(boo)

#func _unhandled_input(event): #LineEdit must have mouse_filter set to 'ignore' in order to prevent mouse input
#	if event is InputEventKey:
#		if event.scancode == KEY_Q:
#			get_child(0).set_focus_mode(2) #Allow Text box to focused
#			get_child(0).grab_focus() #Focus onto textbox
#		elif event.scancode == KEY_ESCAPE:
#			get_child(0).set_focus_mode(0) #prevents textbox from being focused
#
#func _on_LineEdit_text_entered(new_text):
#	get_child(0).clear()
#	for i in list:
#		if new_text == i:
#			print(new_text)
#			list.erase(new_text) #Deletes the Entry
#			return
#	print("Wrong Word")
#	get_child(1).value -= 5


func _on_LineEdit_wrongInput():
	get_node('Left').value -= 5
