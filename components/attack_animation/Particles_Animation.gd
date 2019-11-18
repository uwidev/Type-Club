extends Particles2D
onready var timer = get_node('Timer')

var active = false

export(int) var duration = 1

signal animation_done
signal animation_start

func _process(delta):
	if capture_rect() == Rect2(0,0,0,0) and not is_emitting() and active:
		emit_signal("animation_done")
		active = false


func start_emitting():		
	timer.set_wait_time(duration)
	timer.start()
	emit_signal('animation_start')
	active = true
	set_emitting(true)

func _on_timeout():
	set_emitting(false)