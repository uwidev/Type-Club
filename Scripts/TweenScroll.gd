extends Node2D

# Declare member variables here. Examples:
# var a = 2
# var b = "text"
onready var TweenNode = get_node("Tween")
onready var SpriteNode = get_node("Sprite2")

# Called when the node enters the scene tree for the first time.
func _ready():
	TweenNode.interpolate_property(SpriteNode, "transform/pos", Vector2(0,0), Vector2(300,300), 3, Tween.TRANS_LINEAR, Tween.EASE_IN)
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	TweenNode.start()
