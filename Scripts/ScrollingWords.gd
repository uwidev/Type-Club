extends Node2D

# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var totalWords = 3
var wordOne
var wordTwo
var wordThree
var words = ["First word", "Second word", "Third word"]
var currentWord
var currentIndex = 0
var difference = 300
var pos1 = 100
var pos2 = pos1 + difference
var pos3 = pos2 + difference
var move = difference
var moveSpeed = 20
var moveUp = false
var moveDown = false

# Called when the node enters the scene tree for the first time.
func _ready():
	$Word1.text = words[0]
	$Word2.text = words[1]
	$Word3.text = words[2]
	currentWord = words[currentIndex]
	$Word1.setPosition(Vector2(100,pos1))
	$Word2.setPosition(Vector2(100,pos2))
	$Word3.setPosition(Vector2(100,pos3))

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if moveUp == true:
		if currentIndex == 0:
			$Word1.setPosition(Vector2(100,pos1+move))
			$Word2.setPosition(Vector2(100,pos2+move))
			$Word3.setPosition(Vector2(100,pos3+move))
			if move != 0:
				move -= moveSpeed
		elif currentIndex == 1:
			$Word3.setPosition(Vector2(100,pos1+move))
			$Word1.setPosition(Vector2(100,pos2+move))
			$Word2.setPosition(Vector2(100,pos3+move))
			if move != 0:
				move -= moveSpeed
		elif currentIndex == 2:
			$Word2.setPosition(Vector2(100,pos1+move))
			$Word3.setPosition(Vector2(100,pos2+move))
			$Word1.setPosition(Vector2(100,pos3+move))
			if move != 0:
				move -= moveSpeed
	if moveDown == true:
		if currentIndex == 0:
			$Word1.setPosition(Vector2(100,pos1+move-difference))
			$Word2.setPosition(Vector2(100,pos2+move-difference))
			$Word3.setPosition(Vector2(100,pos3+move-difference))
			if move != difference:
				move += moveSpeed
		elif currentIndex == 1:
			$Word3.setPosition(Vector2(100,pos1+move-difference))
			$Word1.setPosition(Vector2(100,pos2+move-difference))
			$Word2.setPosition(Vector2(100,pos3+move-difference))
			if move != difference:
				move += moveSpeed
		elif currentIndex == 2:
			$Word2.setPosition(Vector2(100,pos1+move-difference))
			$Word3.setPosition(Vector2(100,pos2+move-difference))
			$Word1.setPosition(Vector2(100,pos3+move-difference))
			if move != difference:
				move += moveSpeed

func _input(ev):
	if ev is InputEventKey and ev.is_pressed() and ev.scancode == KEY_UP and not ev.echo:
		moveUp = true
		moveDown = false
		move = difference
		if currentIndex != 0:
        	currentIndex -= 1
		else:
			currentIndex = totalWords-1
	if ev is InputEventKey and ev.is_pressed() and ev.scancode == KEY_DOWN and not ev.echo:
		moveDown = true
		moveUp = false
		move = 0
		if currentIndex != totalWords-1:
        	currentIndex += 1
		else:
			currentIndex = 0