extends MarginContainer

# Declare member variables here. Examples:
var topTE			#Top text engine
var botTE			#Bottom text engine
var dialogueWhereList = []	#Determines whether to display text in top or bot panel
var dialogueTextList = []	#Text to display
var gameoverWhereList = []
var gameoverTextList = []
var last_dialogue_mode = NORMAL_DIALOGUE

enum {NORMAL_DIALOGUE, GAMEOVER_DIALOGUE, LAST_DIALOGUE}

signal dialogue_finished

# Called when the node enters the scene tree for the first time.
func _ready():
	topTE = find_node("Top_Text_Engine")
	topTE.reset()
	botTE = find_node("Bot_Text_Engine")
	botTE.reset()


func link_lists(dW, dT, gW, gT):
	dialogueWhereList = dW
	dialogueTextList = dT
	gameoverWhereList = gW
	gameoverTextList = gT


func next_normal_dialogue():
	_displayText(NORMAL_DIALOGUE)


func gameover_dialogue():
	_displayText(GAMEOVER_DIALOGUE)


func _displayText(mode):
	var where
	var text
	
	grab_focus()
	if mode == LAST_DIALOGUE:
		mode = last_dialogue_mode
	
	if mode == NORMAL_DIALOGUE:
		where = dialogueWhereList.pop_front()
		if where == "done":
			_clear_and_finish()
			return
		text = dialogueTextList.pop_front()
	elif mode == GAMEOVER_DIALOGUE:
		where = gameoverWhereList.pop_front()
		if where == "done":
			_clear_and_finish()
			return
		text = gameoverTextList.pop_front()
	
	last_dialogue_mode = mode
	
	if where != "done":
		topTE.set_state(topTE.STATE_OUTPUT)
		botTE.set_state(botTE.STATE_OUTPUT)
		if where == "top":
			topTE.clear_text()
			topTE.buff_text(text,0.04)
			topTE.buff_break()
		else:
			botTE.clear_text()
			botTE.buff_text(text,0.04)
			botTE.buff_break()
	else:
		_clear_and_finish()


func _clear_and_finish():
	topTE.clear_text()
	botTE.clear_text()
	release_focus()
	emit_signal('dialogue_finished')

func _on_Top_Text_Engine_resume_break():
	_displayText(LAST_DIALOGUE)

func _on_Bot_Text_Engine_resume_break():
	_displayText(LAST_DIALOGUE)

func _input(event):
	if has_focus():
		if event is InputEventKey:
			if event.scancode == KEY_SPACE:
				topTE.set_buff_speed(0)
				botTE.set_buff_speed(0)
			elif not event.scancode == KEY_ENTER:
				accept_event()	#Prevent downward keypress propagation