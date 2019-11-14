extends Node

# Declare member variables here. Examples:
var wordFile	#The opened text file
var wordLine	#The current line
var semiColon	#Position of semicolon
var word	#Word
var pointValue	#How much the word is worth
var wdict = {}	#Key is word, value is points

# Called when the node enters the scene tree for the first time.
func _ready():
	readWords("res://Assets/testLevelWords.txt")
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func readWords(wordTxtFile):
	wordFile = File.new()
	wordFile.open(wordTxtFile,File.READ)
	while(wordFile.eof_reached() == false):
		wordLine = wordFile.get_line()
		semiColon = wordLine.find(";")
		word = wordLine.substr(0,semiColon)
		pointValue = wordLine.substr(semiColon+1,wordLine.length()-3-semiColon)
		wdict[word] = pointValue
		
		