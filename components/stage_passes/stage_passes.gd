extends HBoxContainer

# Declare member variables here
var stageStates = []	#-1: undecided, 0: failed, 1: passed
var currentStage = 0	#Current stage number we are on, starting from 0
var numStages		#Number of stages
var passCount = 0	#Number of passes in level
var failCount = 0	#Number of fails in level
var failThreshold = float(1)/2	#Percentage of fails to trigger level fail

signal game_over
signal level_clear

# Called when the node enters the scene tree for the first time.
func _ready():
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func apply_pass():	#Stage passed
	stageStates[currentStage] = 1
	passCount += 1
	currentStage += 1
	if currentStage == numStages:
		emit_signal("level_clear")

func apply_fail():	#Stage failed
	stageStates[currentStage] = 0
	failCount += 1
	currentStage += 1
	if float(failCount)/numStages >= failThreshold:
		emit_signal("game_over")

func _on_level_ready(number):
	numStages = number
	for i in range(numStages):	#Init stageStates to hold -1's
		stageStates[i] = -1