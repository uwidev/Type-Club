extends Node

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

var wordFile		# The opened text file
var wordLine		# The current line
var semiColon		# Position of semicolon
var word			# Word
var pointValue		# How much the word is worth
var wdicts = []		# List of dictionaries, who contain word:value pairs
var wdict = {}		# This current stage's dictionary
var wlist = []		# Relate to this current stage
var glist = []
var blist = []
var failCount = 0

#export(TextFile) var SceneFile
export var path_words = 'res://'
export(NodePath) var next_scene

signal sendDictList
signal emptyGoodList
signal fail
signal life_mod
signal end_scene

# Called when the node enters the scene tree for the first time.
func _ready():
	readWords(get_filename().trim_suffix('.tscn') + '.txt')		# Will read words from a text file of the same name as this scene
	wdict = wdicts.pop_front()
	for key in wdict.keys():
		wlist.append(key);  #Append words to list
		if wdict[key] > 0:
			glist.append(key)
		else:
			blist.append(key)
	emit_signal("sendDictList", wdict, wlist, glist, blist)
	print("here") #Used to send signal to TypeEngine.gd
	pass # Replace with function body.


func OnSignalFail(): #Change to Signal Function 
	failCount -= 1
	

func readWords(wordTxtFile): #Control has to activate this if used via signal
	wordFile = File.new()
	wordFile.open(wordTxtFile,File.READ)
	while(wordFile.eof_reached() == false):
		wordLine = wordFile.get_line()
		if wordLine == ';;':
			wdicts.append(wdict)
			wdict = {}
		else:
			semiColon = wordLine.find(";")
			word = wordLine.substr(0,semiColon)
			pointValue = int(wordLine.substr(semiColon+1, wordLine.length()))
			wdict[word] = pointValue
	wdicts.append(wdict)
	wordFile.close()
	
	
func _on_text_engine_feedback(word):
	print(wlist, ' | ', word)
	if wdict[word] > 0:
		glist.erase(word)
	else:
		blist.erase(word)
	wlist.erase(word)
	
#	for i in wlist:
#		if i == word && wdict[i] > 0:
#			glist.erase(word)
#			wlist.erase(word)
#
#			print("Erased  " +  word)
#			return
#
#		elif word == i && wdict[i] <= 0: #If 'bad' word, no erasure, submits points for deduction
#			print("Bad Word")
#			return

	if glist.empty():
		if wdicts.empty():
			emit_signal("end_level", next_scene)
			return
		
		emit_signal("emptyGoodList")
		wdict = wdicts.pop_front()

	emit_signal('life_mod', wdict[word])
	wdict.erase(word)


func _on_no_life():
	failCount += 1
	if failCount >= 2:
		emit_signal('fail')