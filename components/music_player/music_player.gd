extends AudioStreamPlayer

# Declare member variables here. Examples:
export(AudioStream) var music_sound
export(bool) var play_on_start
export(bool) var enabled

# Called when the node enters the scene tree for the first time.
func _ready():
	set_stream(music_sound)
	if play_on_start:
		play_music()

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func play_music():
	if enabled:
		play()

func _on_Music_Player_finished():	#Replays music when finished
	play_music()

func set_enabled():
	enabled = true
	
func set_disabled():
	enabled = false