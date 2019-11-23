extends MarginContainer

# Declare member variables here. Examples:
var topTE			#Top text engine
var botTE			#Bottom text engine
var whereList = []	#Determines whether to display text in top or bot panel
var textList = []	#Text to display

var introDialogue

signal loadNextStage
signal startFirstStage

# Called when the node enters the scene tree for the first time.
func _ready():
	topTE = find_node("Top_Text_Engine")
	topTE.reset()
	botTE = find_node("Bot_Text_Engine")
	botTE.reset()

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func _on_base_level_sendTextLists(w,t):
	whereList = w
	textList = t

func _on_base_level_introDialogue():
	introDialogue = true
	_displayText()

func _displayText():
	grab_focus()
	var where = whereList.pop_front()
	print(where)
	if where != "done":
		topTE.set_state(topTE.STATE_OUTPUT)
		botTE.set_state(botTE.STATE_OUTPUT)
		if where == "top":
			topTE.clear_text()
			topTE.buff_text(textList.pop_front(),0.04)
			topTE.buff_break()
		else:
			botTE.clear_text()
			botTE.buff_text(textList.pop_front(),0.04)
			botTE.buff_break()
	else:
		topTE.clear_text()
		botTE.clear_text()
		release_focus()
		if introDialogue == true:
			introDialogue = false
			emit_signal("startFirstStage")
		else:
			emit_signal("loadNextStage")
		
func _on_Enemy_stage_clear():
	_displayText()

#func _on_Top_Text_Engine_resume_break():
#	print("top resume break")
#	_displayText()
#
#func _on_Bot_Text_Engine_resume_break():
#	print("bot resume break")
#	_displayText()

func _input(event):
	if has_focus():
		if event is InputEventKey:
			if event.scancode == KEY_ENTER and event.is_pressed():
				print("ENTER PRESSED")
				_displayText()
				

