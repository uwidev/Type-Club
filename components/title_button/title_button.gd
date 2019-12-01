extends Button

var HOVER = 0

onready var hover = $ButtonHover
onready var select = $ButtonSelect

export(AudioStream) var button_pressed
export(AudioStream) var button_hover

func _ready():
	select.set_stream(button_pressed)
	hover.set_stream(button_hover)

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func _process(delta):
	if is_hovered() and HOVER == 0:
		if hover.is_playing():
			hover.stop()
		hover.play()
		HOVER = 1
	if not is_hovered() and HOVER == 1:
		HOVER = 0
		
func _on_pressed():
	if select.is_playing():
		select.stop()
	select.set_stream(button_pressed)
	select.play()