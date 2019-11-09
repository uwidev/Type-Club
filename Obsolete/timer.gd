extends RichTextLabel

var total_time
var minutes
var seconds
var miliseconds

export(int) var TimerDuration
export(bool) var Autostart

onready var timer = get_node("Timer")
onready var life_bar = get_tree().get_root().get_node("Left")

func on_ready():
	timer.set_wait_time(TimerDuration)
	
		
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
		set_text(str(str("%02d" % seconds)+":"+str("%02d" % miliseconds)))
	else:
		set_text(str("%02d" % minutes)+":"+str("%02d" % seconds))
		
	# Modify Life Bar
	life_bar.set_value(timer.get_time_left()/timer.get_wait_time()*life_bar.get_max())