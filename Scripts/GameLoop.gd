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

export(PackedScene) var next_scene

signal sendDictList
signal refreshedWordDictionary
signal fail
signal life_mod
signal end_level
signal end_all_words

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


func _update_lists(word_dict):
	for w in word_dict:
		wlist.append(w)
		if word_dict[w] > 0:
			glist.append(w)
		else:
			blist.append(w)


func _remove_from_lists(word):
	wlist.erase(word)
	if wdict[word] > 0:
		glist.erase(word)
	else:
		blist.erase(word)


func _generateList(numGood, numBad):
	var mixedList = []
	var randIndex = 0
	var glistSize = glist.size()
	var blistSize = blist.size()
	randomize()		#Randomizes a new seed for random number generator
	while numGood != 0:
		randIndex = randi()%glistSize	#Returns random int between 0 and glistSize-1
		if mixedList.has(glist[randIndex]) == false:
			mixedList.append(glist[randIndex])
			numGood -= 1
	while numBad != 0:
		randIndex = randi()%blistSize
		if mixedList.has(blist[randIndex]) == false:
			mixedList.append(blist[randIndex])
			numBad -= 1
	mixedList.shuffle()	#Shuffles list for a random order
	return mixedList


func _generateListPercentage(numWords, percentGood):
	var good = ceil(numWords*percentGood)	#Ensures there's always one good word so long as percentage != 0
	var bad = numWords-good
	return _generateList(good,bad)


func _on_text_engine_feedback(word):
	var tmp_dict
	
	_remove_from_lists(word)

	emit_signal('life_mod', wdict[word])
	wdict.erase(word)
	
	print('gameloop: ', wdict, ' | ', word)
	if glist.empty():			# Denotes the end of a stage
		if wdicts.empty():		# Denotes the end of a level
			emit_signal('end_all_words')
			emit_signal("end_level", next_scene)
			return
		
		# If not empty, queue the next stage...
		# Optionally queue small cutscene (when implimented)
		tmp_dict =  wdicts.pop_front()
		for key in tmp_dict.keys():
			wdict[key] = tmp_dict[key]
		_update_lists(wdict)
		
		emit_signal("refreshedWordDictionary")
		return

	
func _on_no_life():
	failCount += 1
	if failCount >= 2:
		emit_signal('fail')