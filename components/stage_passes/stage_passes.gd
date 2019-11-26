extends HBoxContainer

# Declare member variables here
var stageStates = []	#-1: undecided, 0: failed, 1: passed
var currentStage = 0	#Current stage number we are on, starting from 0
var numStages		#Number of stages
var passCount = 0	#Number of passes in level
var failCount = 0	#Number of fails in level
var failThreshold = float(1)/2	#Percentage of fails to trigger level fail
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
	
	_on_level_ready(3)
	apply_pass()
	apply_pass()
	apply_fail()

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func apply_pass():	#Stage passed
	stageStates[currentStage] = 1
	passCount += 1
	imageList[currentStage].set_texture(stateTextures[1])
	currentStage += 1
	if currentStage == numStages:
		print("level cleared")
		emit_signal("level_clear")

func apply_fail():	#Stage failed
	stageStates[currentStage] = 0
	failCount += 1
	imageList[currentStage].set_texture(stateTextures[0])
	currentStage += 1
	if float(failCount)/numStages >= failThreshold:
		print("game over")
		emit_signal("game_over")
	elif currentStage == numStages:
		print("level cleared")
		emit_signal("level_clear")

func _on_level_ready(number):
	numStages = number
	for i in range(numStages):	#Init stageStates to hold -1's
		stageStates.append(-1)