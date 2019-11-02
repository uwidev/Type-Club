extends RichTextLabel

var ms = 0
var s = 0
var m = 1


func _process(delta):
	
	if ms < 0 :
		s -= 1
		ms = 9
	
	if s < 0 :
		m -= 1
		s = 59 
	
	set_text(str(m)+":"+str(s)+":"+str(ms))
	
	pass 


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_Timer_timeout():
	ms -= 1
	
	pass 
