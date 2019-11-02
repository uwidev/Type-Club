extends RichTextLabel

var ms = 0
var s = 0 
var m = 1 
 

# Called when the node enters the scene tree for the first time.
func _process(delta):
	
	print(ms)
	if ms < 0 :
		s +=1
		ms = 0
		
		if s > 59 :
			m += 1
			s = 0
	set_text(str(m)+":"+str(s)+":"+str(ms))	
	pass 


func _on_Timer_timeout():
	ms -= 1
