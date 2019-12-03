extends AudioStreamPlayer

export(AudioStream) var normal
export(AudioStream) var large

func play_normal():
	if is_playing():
		stop()
	set_stream(normal)
	play()
	
func play_large():
	if is_playing():
		stop()
	set_stream(large)
	play()