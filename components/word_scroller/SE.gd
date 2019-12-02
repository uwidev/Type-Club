extends AudioStreamPlayer

func play_scroll():
	if is_playing():
		stop()
	play()