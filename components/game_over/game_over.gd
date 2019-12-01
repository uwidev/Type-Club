extends Panel

# Declare member variables here. Examples:
var enemy

signal request_retry
signal request_main_menu

export(Texture) var enemyImage

# Called when the node enters the scene tree for the first time.
func _ready():
	enemy = find_node("Enemy")
	enemy.set_texture(enemyImage)

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func _on_Retry_pressed(): #Retry the level
	emit_signal("request_retry")


func _on_Main_Menu_pressed():
	emit_signal("request_main_menu")
