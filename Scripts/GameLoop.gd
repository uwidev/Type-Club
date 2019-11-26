extends "res://Scenes/LoadableScene.gd"

# Declare member variables here

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
var stage_clear_flag = false
var gamestate = PLAYING
var whereList = []	#Determines whether to display text in top or bot panel
var textList = []	#Text to display

export(PackedScene) var next_scene
#export(int, 'Gen by int', 'Gen by percentage') var gen_mode
#export(Array, int) var player_life
export(int) var additional_good_words
export(int) var additional_bad_words
export(bool) var unique_good
export(bool) var unique_bad
export(bool) var erase_on_good = true
export(bool) var erase_on_bad = false


enum {GENINT, GENPERCENTAGE}
enum {PLAYING, END, WAIT, DIALOGUE}

export(int) var wrongWordPenalty = -5

signal sendDictList
signal refreshedWordDictionary
signal fail
signal life_mod
signal stage_ready
signal cycle_done
signal sendTextLists
signal introDialogue
signal prepare_stage

onready var enemy = find_node('Enemy')
onready var scroller = find_node('Word Scroller')
onready var typer = find_node('Type Engine')
onready var timerlife = find_node('Life and Timer')

# Called when the node enters the scene tree for the first time.
func _ready():
	if get_owner() == null:
		readWords(get_filename().trim_suffix('.tscn') + '.txt')		# Will read words from a text file of the same name as this scene
	else:
		readWords(get_owner().get_filename().trim_suffix('.tscn') + '.txt')		# Will read words from a text file of the same name as this scene
	wdict = wdicts.pop_front()
	_update_gblists(wdict)
	
	wlist = _generateList(enemy.lifeList.front() + additional_good_words, additional_bad_words)
	
	emit_signal("sendDictList", wdict, wlist, glist, blist)
	emit_signal("sendTextLists", whereList, textList)
	emit_signal("introDialogue")	#Send signal to text panels to handle intro dialogue before starting first stage


func OnSignalFail(): #Change to Signal Function 
	failCount -= 1
	

func readWords(wordTxtFile): #Control has to activate this if used via signal
	wordFile = File.new()
	wordFile.open(wordTxtFile,File.READ)
	var doneWithWords = false	#True when all stage words are read
	while(wordFile.eof_reached() == false):
		wordLine = wordFile.get_line()
		if doneWithWords == false:
			if wordLine == ';;':
				wdicts.append(wdict)
				wdict = {}
			elif wordLine == ';;;':
				doneWithWords = true
			else:
				semiColon = wordLine.find(";")
				word = wordLine.substr(0,semiColon)
				pointValue = int(wordLine.substr(semiColon+1, wordLine.length()))
				wdict[word] = pointValue
		else:
			#Now read text for top and bot display
			if wordLine == ';;;':
				whereList.append("done")
			else:	
				semiColon = wordLine.find(";")
				word = wordLine.substr(0,semiColon)
				whereList.append(word)	#Word should be "top" or "bot"
				textList.append(wordLine.substr(semiColon+1, wordLine.length()))


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
	while numGood != 0 and glistSize != 0:
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


func _on_no_life():
	failCount += 1
	print('fail')
	if failCount >= 2:
		emit_signal('fail')
		print('game over')


func _on_good_word(word):
	# Self heal
	timerlife.paused(true)
	timerlife.offset_life(wdict[word])
	
	# Attack Animation
	$AnimationPlayer.play('attack_animation')
	
	# Erase word to shoot at enemy
	if erase_on_good:
		wlist.erase(word)
	
	# Wait for attack animation to finish
	yield($AnimationPlayer, "animation_finished")
	
	#print('gamestate: ', gamestate)
	if gamestate == PLAYING:
		emit_signal('cycle_done')


func _load_next_stage():
	if gamestate == PLAYING:
		var tmp = wdicts.pop_front()
		
		wdict.clear()
		
		for key in tmp:
			wdict[key] = tmp[key]
		
		_update_gblists(wdict)
		
		wlist.clear()
		for word in _generateList(enemy.lifeList.front() + additional_good_words, additional_bad_words):
			wlist.append(word)
		
		emit_signal('prepare_stage')
		
		print('now yielding until words are fully visible')
		yield(scroller, 'words_fully_visible')
		
		gamestate = PLAYING
		emit_signal('stage_ready')


func _on_bad_word(word):
	# some hit animation here
	timerlife.offset_life(wdict[word])
	
	if erase_on_bad:
		wlist.erase(word)
	emit_signal('cycle_done')


func _on_Text_Panels_loadNextStage():
	gamestate = PLAYING
	_load_next_stage()
	


func _on_Text_Panels_startFirstStage():
	#Signal to start first stage received from text panels
	emit_signal('prepare_stage')
		
	yield(scroller, 'words_fully_visible')
	
	emit_signal('stage_ready')


func _on_Text_Panels_endLevel():
	#Signal that the enemy has died
	#$"VBoxContainer/Life and Timer".toggle_locked()
	#$"VBoxContainer/Life and Timer".paused(true)
	gamestate = END
	print("END LEVEL")
	emit_signal('end_level', next_scene)


func _on_enemy_life_depleted():
	gamestate = DIALOGUE