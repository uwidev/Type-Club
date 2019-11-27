extends LineEdit


var debug_list = ['math', 'science', 'video games']
# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var wdict = {}	#Key is word, value is points
var wlist = []
var glist = []
var blist = []
signal emptyList 	# Win Condition
signal entered_good
signal entered_bad
signal request_scroller
var current_word	# Current typing word
var cursor			# Incoming char index of current_word needed to type

onready var typing_label 

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

#IN ORDER TO WORK WITH SCROLL UI, PROBABLY CHANGE TO DIFFERENT SIGNAL WITH GIVEN NECESSARY INPUT "FIRST CHAR OF WORD"
func _input(event): #LineEdit must have mouse_filter set to 'ignore' in order to prevent mouse input
	if has_focus():
		if event is InputEventKey:
			if event.pressed:
				#print('typed: ', char(event.get_unicode()), ' | ', current_word[cursor])
				if cursor < current_word.length() and char(event.get_unicode()) == current_word[cursor]:
						cursor += 1
				elif cursor >= current_word.length() and event.get_scancode() == KEY_ENTER:
					pass
				elif event.get_scancode() == KEY_BACKSPACE and cursor >= 1:
					if cursor == 1:
						emit_signal('request_scroller')
						set_text('')
					else:					
						cursor -= 1
				else:
					accept_event()
	
	#Add Victory/Loss Manager
	

func link_dict_list(d, l):
	#print('type engine dicts recieved')
	wdict = d
	wlist = l


func _on_word_selected(word, pos):
	set_global_position(pos)
	current_word = word
	append_at_cursor(current_word[0])
	cursor = 1
	grab_focus()


func _on_text_entered(word):
	release_focus()
	self.clear()
	current_word = ''
	if wdict[word] > 0:
		emit_signal('entered_good', word)
	else:
		emit_signal('entered_bad', word)


func _on_scroller_redraw():
	typing_label.get_global_position()


func _on_scroller_redrew(pos):
	set_global_position(pos)
