extends AudioStreamPlayer

export(Array, AudioStream) var SE

func play_pass():
	set_stream(SE[0])
	play()

func play_fail():
	set_stream(SE[1])
	play()