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
var dialogueWhereList = []	#Determines whether to display text in top or bot panel
var dialogueTextList = []	#Text to display
var gameoverWhereList = []
var gameoverTextList = []

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
onready var textpanel = find_node('Text Panels')
onready var stageindicator = find_node('Stage Pass Indicator')
onready var animation = find_node('AnimationPlayer')
onready var particles = find_node('Attack Particles')

# Called when the node enters the scene tree for the first time.
func _ready():
	if get_owner() == null:
		_readWords(get_filename().trim_suffix('.tscn') + '.txt')		# Will read words from a text file of the same name as this scene
	else:
		_readWords(get_owner().get_filename().trim_suffix('.tscn') + '.txt')		# Will read words from a text file of the same name as this scene
	wdict = wdicts.pop_front()
	_update_gblists(wdict)
	
	wlist = _generateList(enemy.lifeList.front() + additional_good_words, additional_bad_words)
	

	scroller.link_lists(wdict, wlist)
	typer.link_dict_list(wdict, wlist)
	textpanel.link_lists(dialogueWhereList, dialogueTextList, gameoverWhereList, gameoverTextList)
	stageindicator.on_stage_ready(wdicts.size() + 1)
	
	textpanel.next_normal_dialogue()
	yield(textpanel, 'dialogue_finished')
	
	emit_signal("prepare_stage")
	
	yield(scroller, 'words_fully_visible')
	
	emit_signal('stage_ready')

# Ready Helper Functions
func _readWords(wordTxtFile): #Control has to activate this if used via signal
	wordFile = File.new()
	wordFile.open(wordTxtFile,File.READ)
	var doneWithWords = false	#True when all stage words are read
	var doneWithDialogue = false
	var doneWithGameOver = false
	while(wordFile.eof_reached() == false):
		wordLine = wordFile.get_line()
		if not doneWithWords:
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
		
		elif not doneWithDialogue:
			#Now read text for top and bot display
			if wordLine == ';;;':
				dialogueWhereList.append("done")
			elif wordLine == ';;;;':
				doneWithDialogue = true
			else:	
				semiColon = wordLine.find(";")
				word = wordLine.substr(0,semiColon)
				dialogueWhereList.append(word)	#Word should be "top" or "bot"
				dialogueTextList.append(wordLine.substr(semiColon+1, wordLine.length()))
		
		elif not doneWithGameOver:
			if wordLine == ';;;':
				gameoverWhereList.append("done")
			else:	
				semiColon = wordLine.find(";")
				word = wordLine.substr(0,semiColon)
				gameoverWhereList.append(word)	#Word should be "top" or "bot"
				gameoverTextList.append(wordLine.substr(semiColon+1, wordLine.length()))

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


# Signals from Typing Engine
func _on_good_word(word):
	# Self heal
	timerlife.paused(true)
	timerlife.offset_life(wdict[word])
	
	# Attack Animation
	animation.play('attack_animation')
	
	# Erase word to shoot at enemy
	if erase_on_good:
		wlist.erase(word)
	
	# Wait for attack animation to finish
	yield(animation, "animation_finished")
	
	#print('gamestate: ', gamestate)
	if gamestate == PLAYING:
		emit_signal('cycle_done')

func _on_bad_word(word):
	# some hit animation here
	timerlife.offset_life(wdict[word])
	
	if erase_on_bad:
		wlist.erase(word)
	emit_signal('cycle_done')

# Helper functions
func _load_next_stage():
	if gamestate == DIALOGUE or gamestate == WAIT:
		var tmp = wdicts.pop_front()
		
		wdict.clear()
		
		for key in tmp:
			wdict[key] = tmp[key]
		
		_update_gblists(wdict)
		
		wlist.clear()
		for word in _generateList(enemy.lifeList.front() + additional_good_words, additional_bad_words):
			wlist.append(word)
		
		emit_signal('prepare_stage')
		
		#print('now yielding until words are fully visible')
		yield(scroller, 'words_fully_visible')
		
		gamestate = PLAYING
		emit_signal('stage_ready')


# Called by life/timer
func _on_no_life():
	stageindicator.apply_fail()
	print('FAIL')


# Called right before stage_clear (enemy is dead)
func _on_enemy_life_depleted():
	gamestate = WAIT


# Called from enemy when stage passed
func _on_stage_clear():
	# Pause timer and apply pass, scroller hide
	stageindicator.apply_pass()
	scroller.stage_clear_hide()
	timerlife.halt_and_lock()
	
	# Check if we're still in WAIT, and if so
	# queue the next normal dialogue and wait for it 
	# before loading in next level
	#print('gamestate: ',gamestate)
	if gamestate == WAIT:
		print('STAGE CLEAR')
		gamestate == DIALOGUE
		textpanel.next_normal_dialogue()
		yield(textpanel, 'dialogue_finished')
		
		_load_next_stage()


# Called by stageindicator when game over
func _on_game_over():
	gamestate = END
	
	textpanel.gameover_dialogue()
	yield(textpanel, 'dialogue_finished')
	
	print('GAME OVER')
	# Show game over, ask restart or main menu
	
	
# Called by stageindicator when win conditions are met
func _on_win_level_over():
	#print('win level')
	gamestate = END
	
	textpanel.next_normal_dialogue()
	yield(textpanel, 'dialogue_finished')
	
	print('WIN')
	emit_signal('end_level', next_scene)