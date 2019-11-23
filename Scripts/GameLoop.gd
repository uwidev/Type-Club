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

var topTE			#Top text engine
var botTE			#Bottom text engine
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

onready var enemy = find_node('Enemy')

# Called when the node enters the scene tree for the first time.
func _ready():
	if get_owner() == null:
		readWords(get_filename().trim_suffix('.tscn') + '.txt')		# Will read words from a text file of the same name as this scene
	else:
		readWords(get_owner().get_filename().trim_suffix('.tscn') + '.txt')		# Will read words from a text file of the same name as this scene
	wdict = wdicts.pop_front()
	_update_gblists(wdict)
	
	wlist = _generateList(enemy.lifeList.front() + additional_good_words, additional_bad_words)
	
	topTE = find_node("Top_Text_Engine")
	topTE.reset()
	botTE = find_node("Bot_Text_Engine")
	botTE.reset()
	
	emit_signal("sendDictList", wdict, wlist, glist, blist)
	emit_signal('stage_ready')


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


func _on_no_life():
	failCount += 1
	print('fail')
	if failCount >= 2:
		emit_signal('fail')
		print('game over')


func _on_enemy_dead():
	$"VBoxContainer/Life and Timer".toggle_locked()
	$"VBoxContainer/Life and Timer".paused(true)
	gamestate = END
	print("END LEVEL")
	emit_signal('end_level', next_scene)


func _on_good_word(word):
	# Self heal
	$VBoxContainer/"Life and Timer".paused(true)
	$VBoxContainer/"Life and Timer".offset_life(wdict[word])
	
	# Attack Animation
	$AnimationPlayer.play('attack_animation')
	
	# Erase word to shoot at enemy
	if erase_on_good:
		wlist.erase(word)
	
	# Wait for attack animation to finish
	yield($AnimationPlayer, "animation_finished")
	
	#enemy.take_damage(1)
	if gamestate == PLAYING:
		emit_signal('cycle_done')


func _load_next_stage():
	if gamestate == PLAYING:
		var tmp = wdicts.pop_front()
		
		wdict.clear()
		
#		gamestate = DIALOGUE
#		yield()		#Yield for showing dialogue text
#		gamestate = PLAYING
		
		for key in tmp:
			wdict[key] = tmp[key]
		
		_update_gblists(wdict)
		
		wlist.clear()
		for word in _generateList(enemy.lifeList.front() + additional_good_words, additional_bad_words):
			wlist.append(word)
			
		emit_signal('stage_ready')


func _on_bad_word(word):
	# some hit animation here
	$VBoxContainer/"Life and Timer".offset_life(wdict[word])
	
	if erase_on_bad:
		wlist.erase(word)
	emit_signal('cycle_done')

func _displayText():
	topTE.set_state(topTE.STATE_OUTPUT)
	botTE.set_state(botTE.STATE_OUTPUT)
	var where = whereList.pop_front()
	if where != "done":
		if where == "top":
			topTE.clear_text()
			topTE.buff_text(textList.pop_front(),0.04)
			topTE.buff_break()
		else:
			botTE.clear_text()
			botTE.buff_text(textList.pop_front(),0.04)
			botTE.buff_break()
	else:
		pass
		#_load_next_stage().resume()

func _on_stage_clear():
	_load_next_stage()
	_displayText()
#	topTE.clear_text()
#	botTE.clear_text()
#	topTE.set_state(topTE.STATE_WAITING)
#	botTE.set_state(botTE.STATE_WAITING)
#	_load_next_stage()

func _on_Top_Text_Engine_resume_break():
	_displayText()


func _on_Bot_Text_Engine_resume_break():
	_displayText()
