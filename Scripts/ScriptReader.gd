extends Control

# Declare member variables here. Examples:
var textEngine
var script
var readLine
var semiColon
var charName

# Called when the node enters the scene tree for the first time.
func _ready():
	textEngine = get_node("Panel/Text_Engine")
	readScript("res://Assets/scriptTester.txt")

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func readScript(scriptFile):
	script = File.new()
	script.open(scriptFile,File.READ)
	textEngine.reset()
	textEngine.set_state(textEngine.STATE_OUTPUT)
	textEngine.set_color(Color(100,100,100))
	while (script.eof_reached() != true):
		readLine = script.get_line()
		if readLine.begins_with("Image"):
			pass
		elif readLine.begins_with("Scene"):
			pass
		else:
			textEngine.buff_clear()
			semiColon = readLine.find(";")
			charName = readLine.substr(0,semiColon)
			readLine = readLine.substr(semiColon+1,readLine.length()-semiColon)
			textEngine.buff_text(charName+"\n",0)
			textEngine.buff_text(readLine,0.1)
			textEngine.buff_silence(1)
	