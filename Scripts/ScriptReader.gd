extends "res://Scenes/LoadableScene.gd"

# Declare member variables here. Examples:
var textEngine
var script
var readLine	#Individual line read
var semiColon	#Index of semicolon
var charName	#Name of character speaking
var afterSC		#Text after the semicolon
var image		#The TextureRect node to display images on

export(PackedScene) var nextScene

# Called when the node enters the scene tree for the first time.
func _ready():
	textEngine = find_node("Text_Engine")
	image = find_node("imageToShow")
	if get_owner() == null:
		readScript(get_filename().trim_suffix('.tscn') + '.txt')		# Will read words from a text file of the same name as this scene
	else:
		readScript(get_owner().get_filename().trim_suffix('.tscn') + '.txt')		# Will read words from a text file of the same name as this scene
	
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func readScript(scriptFile):
	script = File.new()
	script.open(scriptFile,File.READ)
	textEngine.reset()
	textEngine.set_state(textEngine.STATE_OUTPUT)
# warning-ignore:unused_variable
#	for i in range(GlobalVariables.scriptLine):		#Skip to the right line
#		script.get_line()
	readNextLine()
		
func readNextLine():
#	GlobalVariables.scriptLine += 1
	if(script.eof_reached() != true):
		readLine = script.get_line()
		semiColon = readLine.find(";")
		afterSC = readLine.substr(semiColon+1,readLine.length()-semiColon)
		if readLine == '' or readLine.begins_with('#'):
			readNextLine()
		elif readLine.begins_with("Prompt"):
			textEngine.buff_text(afterSC,0.04)
			textEngine.buff_text('>> ',0.04)
			textEngine.buff_input()
			textEngine.buff_text("\n",0)
		elif readLine.begins_with("Image"):
			image.set_texture(load(afterSC))
			readNextLine()
		else:
			charName = readLine.substr(0,semiColon)
			if charName != "Narrator":
				textEngine.buff_text(charName+"\n",0)
			textEngine.buff_text(afterSC,0.04)
			textEngine.buff_break()
			textEngine.buff_text("\n",0)
	else:
		print('EOF Reached, emiting end_level')
		emit_signal("end_level", nextScene)

func _on_Text_Engine_resume_break():	#Enter was pressed, resume text
	readNextLine()

func _input(ev):
	if ev is InputEventKey and ev.scancode == KEY_SPACE and not ev.echo:
        textEngine.set_buff_speed(0)

func _on_Text_Engine_input_enter(input):	#Check if player typed correct prompt
	if input == afterSC:	#afterSC currently holds the prompt
		readNextLine()
	else:
		textEngine.buff_text(afterSC,0.04)
		textEngine.buff_text('>> ',0.04)
		textEngine.buff_input()
		textEngine.buff_text("\n",0)
