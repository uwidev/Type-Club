extends HBoxContainer

# Declare member variables here
var stageStates = []	#-1: undecided, 0: failed, 1: passed
var currentStage = -1	#Current stage number we are on, starts at index 0
var numStages		#Number of stages
var passCount = 0	#Number of passes in level
var failCount = 0	#Number of fails in level
var failThreshold = 2	#Fails allowed excluding final stage
var imageList = []	#Contains the texture nodes
var image1
var image2
var image3

signal game_over
signal level_clear

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
	
	if currentStage == numStages:
		emit_signal("level_clear")

func apply_fail():	#Stage failed
	if stageStates[currentStage] == -1:
		stageStates[currentStage] = 0
		failCount += 1
		imageList[currentStage].set_texture(stateTextures[0])
	
	if currentStage == numStages or failCount >= failThreshold:
		emit_signal("game_over")

func on_stage_ready(number):
	numStages = number - 1
	for i in range(numStages + 1):	#Init stageStates to hold -1's
		stageStates.append(-1)