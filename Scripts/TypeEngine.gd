extends LineEdit

# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var totalList = []
var goodList  = []
var badList = []
var wordDict = {}
signal input
signal emptyList #Win Condition

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func _on_LineEdit_text_entered(new_text):
	self.clear()
	if goodList.empty():
		emit_signal("emptyList")
		return
	for i in totalList:
		if new_text == i && wordDict[i] > 0:
			goodList.erase(new_text) #Deletes the Entry
			totalList.erase(new_text)
			if goodList.empty():
				emit_signal("emptyList") #Done with level
				return
			emit_signal("input", wordDict[i]) #If given dict, pass WordDict[i]
			print("Erased  " +  new_text)
			return
		elif new_text == i && wordDict[i] <= 0: #If 'bad' word, no erasure, submits points for deduction
			emit_signal("input", wordDict[i])
			print("Bad Word")
			return
	emit_signal("input", 5) #Random value for wrong word
	print("Wrong Spelling")

#IN ORDER TO WORK WITH SCROLL UI, PROBABLY CHANGE TO DIFFERENT SIGNAL WITH GIVEN NECESSARY INPUT "FIRST CHAR OF WORD"
func _unhandled_input(event): #LineEdit must have mouse_filter set to 'ignore' in order to prevent mouse input
	if event is InputEventKey:
		if event.scancode == KEY_Q:
			self.set_focus_mode(2) #Allow Text box to focused
			self.grab_focus() #Focus onto textbox
		elif event.scancode == KEY_ESCAPE:
			self.set_focus_mode(0) #prevents textbox from being focused
	
	
	#Add Victory/Loss Manager


func _on_Node_sendDictList(dict, tlist, glist):
	totalList = tlist
	wordDict = dict
	goodList = glist
