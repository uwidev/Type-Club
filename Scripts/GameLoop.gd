extends "res://Scenes/LoadableScene.gd"

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
onready var enemy = find_node('Enemy')

export(PackedScene) var next_scene
#export(int, 'Gen by int', 'Gen by percentage') var gen_mode
export(int) var additional_good_words
export(int) var additional_bad_words
export(bool) var unique_good
export(bool) var unique_bad

enum {GENINT, GENPERCENTAGE}

export(int) var wrongWordPenalty = -5

signal sendDictList
signal refreshedWordDictionary
signal fail
signal life_mod
signal wlist_ready


# Called when the node enters the scene tree for the first time.
func _ready():
	readWords(get_filename().trim_suffix('.tscn') + '.txt')		# Will read words from a text file of the same name as this scene
	wdict = wdicts.pop_front()
	_update_gblists(wdict)
	
	wlist = _generateList(enemy.currentLife + additional_good_words, additional_bad_words)
	print(wlist)
	
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


func _update_gblists(word_dict):
	glist.clear()
	blist.clear()
	for w in word_dict:
		if word_dict[w] > 0:
			glist.append(w)
		else:
			blist.append(w)


func _generateList(numGood, numBad):
	var mixedList = []
	var randIndex = 0
	var glistSize = glist.size()
	var blistSize = blist.size()
	randomize()		#Randomizes a new seed for random number generator
	while numGood != 0:
		randIndex = randi()%glistSize	#Returns random int between 0 and glistSize-1
		if unique_good:
			if not mixedList.has(glist[randIndex]):
				mixedList.append(glist[randIndex])
				numGood -= 1
		else:
			mixedList.append(glist[randIndex])
			numGood -= 1
	if blistSize != 0:
		while numBad != 0:
			randIndex = randi()%blistSize
			if unique_bad:
				if not mixedList.has(blist[randIndex]):
					mixedList.append(blist[randIndex])
					numBad -= 1
			else:
				mixedList.append(blist[randIndex])
				numBad -= 1
	mixedList.shuffle()	#Shuffles list for a random order
	return mixedList


func _generateListPercentage(numWords, percentGood):
	var good = ceil(numWords*percentGood)	#Ensures there's always one good word so long as percentage != 0
	var bad = numWords-good
	return _generateList(good,bad)


func _on_text_engine_feedback(word):
	emit_signal('life_mod', wdict.get(word, 0))
	wlist.erase(word)
	
	
func _on_no_life():
	failCount += 1
	if failCount >= 2:
		emit_signal('fail')


func _on_enemy_dead():
	emit_signal('end_level', next_scene)


func _on_stage_clear():
	wdict = wdicts.pop_front()
	_update_gblists(wdict)
	wlist.clear()
	for word in _generateList(enemy.currentLife + additional_good_words, additional_bad_words):
		wlist.append(word)
	emit_signal('wlist_ready')