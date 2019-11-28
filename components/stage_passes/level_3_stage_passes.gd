extends HBoxContainer

# Declare member variables here
var stageStates = []	#-1: undecided, 0: failed, 1: passed
var currentStage = -1	#Current stage number we are on, starts at index 0 after ready signal
var numStages		#Number of stages
var passCount = 0	#Number of passes in level
var failCount = 0	#Number of fails in level
var failThreshold = 0	#Fails allowed for final level
var imageList = []	#Contains the texture nodes
var image1
var image2
var image3

signal game_over
signal level_clear
signal applied

export(Array, Texture) var stateTextures

# Called when the node enters the scene tree for the first time.
func _ready():
	image1 = find_node("NinePatchRect")
	image2 = find_node("NinePatchRect2")
	image3 = find_node("NinePatchRect3")
	imageList = [image1, image2, image3]

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func _on_stage_ready():
	currentStage += 1

func apply_pass():	#Stage passed
	if stageStates[currentStage] == -1:
		stageStates[currentStage] = 1
		passCount += 1
		imageList[currentStage].set_texture(stateTextures[1])
	
	print(currentStage, ' ', numStages)
	
	emit_signal("applied")

func apply_fail():	#Stage failed
	if stageStates[currentStage] == -1:
		stageStates[currentStage] = 0
		failCount += 1
		imageList[currentStage].set_texture(stateTextures[0])
	
	if currentStage == numStages:
		#Expected to fail the last level, so level clear
		emit_signal("level_clear")
	elif failCount > failThreshold:
		#Failed before reaching final stage
		emit_signal("game_over")
	
	emit_signal("applied")

func on_stage_ready(number):
	numStages = number - 1
	for i in range(numStages + 1):	#Init stageStates to hold -1's
		stageStates.append(-1)