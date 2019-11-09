extends Node

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

var wordFile	#The opened text file
var wordLine	#The current line
var semiColon	#Position of semicolon
var word	#Word
var pointValue	#How much the word is worth
var wordDict = {}	#Key is word, value is points
var list = []
var glist = []

var failCount = 0

export(TextFile) var SceneFile

signal sendDictList
signal fail

# Called when the node enters the scene tree for the first time.
func _ready():
	readWords(SceneFile)
	for i in wordDict.keys():
		list.append(i);  #Append words to list
		if wordDict[i] > 0:
			glist.append(i)
	emit_signal("sendDictList", wordDict, list, glist) #Used to send signal to TypeEngine.gd
	pass # Replace with function body.

func OnSignalFail(): 
	failCount -= 1

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if(failCount <= -2):
		emit_signal("fail") #Emits fail signal

func readWords(wordTxtFile): #Control has to activate this if used via signal
	wordFile = File.new()
	wordFile.open(wordTxtFile,File.READ)
	while(wordFile.eof_reached() == false):
		wordLine = wordFile.get_line()
		semiColon = wordLine.find(";")
		word = wordLine.substr(0,semiColon)
		pointValue = wordLine.substr(semiColon+1,wordLine.length()-3-semiColon)
		wordDict[word] = pointValue