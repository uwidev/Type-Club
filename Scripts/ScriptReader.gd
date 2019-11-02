extends Control

# Declare member variables here. Examples:
var textEngine
var script
var readLine	#Individual line read
var semiColon	#Index of semicolon
var charName	#Name of character speaking
var afterSC		#Text after the semicolon
var image		#Image to load

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
	textEngine.set_color(Color(100,100,100))		#Doesn't seem to affect color
	for i in range(GlobalVariables.scriptLine):		#Skip to the right line
		script.get_line()
	
	readNextLine()
		
func readNextLine():
	GlobalVariables.scriptLine += 1
	if(script.eof_reached() != true):
		readLine = script.get_line()
		semiColon = readLine.find(";")
		afterSC = readLine.substr(semiColon+1,readLine.length()-semiColon)
		if readLine.begins_with("Prompt"):
			textEngine.buff_input()
		elif readLine.begins_with("Image"):
			pass
#			image = Image.new()
#			image.load(afterSC)
#			var imgTexture = ImageTexture.new()
#			imgTexture.create_from_image(image)
		elif readLine.begins_with("Scene"):
			GlobalVariables.switchScene(afterSC)
		else:
			charName = readLine.substr(0,semiColon)
			textEngine.buff_text(charName+"\n",0)
			textEngine.buff_text(afterSC,0.05)
			textEngine.buff_break()
		textEngine.buff_clear()	
	

func _on_Text_Engine_buff_cleared():
	readNextLine()
