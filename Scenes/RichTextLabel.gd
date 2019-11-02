extends RichTextLabel

var ms = 0
var s = 10
var m = 0
var current_time = 100
var max_time = m*60+s
var secondshealth


func _process(delta):
	
	
	
	if ms < 0 :
		s -= 1
		ms = 9
	
	if s < 0 :
		m -= 1
		s = 59 
	
	set_text(str(m)+":"+str(s)+":"+str(ms))
	current_time = m + s + ms
	secondshealth = 60*m + s + .1*ms
	var life = get_parent().get_node("Right")
	life.value = float(secondshealth)/float(max_time) * 100.0
	# life.value = life.value - 1
	pass 


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_Timer_timeout():
	ms -= 1
	
	pass 




