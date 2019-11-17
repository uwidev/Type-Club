extends Control

var total_time
var minutes
var seconds
var miliseconds
var locked = false

export(int) var MaxTimeLife = 20
export(bool) var Autostart

onready var label_left = get_node("Timer/left")
onready var label_right = get_node("Timer/right")
onready var timer = get_node("Timer/Timer")
onready var life_bar = get_node("Left")

signal no_life

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
	if not minutes:
		label_left.set_text(str("%02d" % seconds))
		label_right.set_text(str("%02d" % miliseconds))
	else:
		label_left.set_text(str("%02d" % minutes))
		label_right.set_text(str("%02d" % seconds))
		
	# Modify Life Bar
	life_bar.set_value(timer.get_time_left()/MaxTimeLife*life_bar.get_max())
	
	# Testing/Debugging purposes
#	if Input.is_action_just_pressed("ui_right"):
#		if not timer.is_paused():
#			paused(true)
#		else:
#			paused(false)
#
#	if Input.is_action_just_pressed("ui_left"):
#		offset_life_percent(.2)
	
	
# Given an number, offset life by that much
func offset_life(time):
	if not locked:
		if time is int or time is float:
			timer.set_wait_time(max(min(MaxTimeLife, timer.get_time_left()+time), 0.001))
			timer.start()
			life_bar.set_value(timer.get_time_left()/MaxTimeLife*life_bar.get_max())


# Given a decimal, offset life by that much
func offset_life_percent(percent):
	if not locked:
		if percent is int or percent is float:
			timer.set_wait_time(min(timer.get_time_left()*(1+percent), MaxTimeLife))
			timer.start()
			life_bar.set_value(timer.get_time_left()/MaxTimeLife*life_bar.get_max())


# Accepts boolean to pause or unpause
func paused(boo):
	if boo is bool:
		timer.set_paused(boo)


func _on_life_mod(value):
	offset_life(value)


func _on_no_life():
	locked = true
	emit_signal('no_life')


func _on_emptyGoodList():

	pass


func _on_fail():
	paused(true)
