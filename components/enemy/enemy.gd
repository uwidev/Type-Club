extends Control

var _start_position = 0
var _trauma
var shaking = false
var currentLife = 0
var futureLife = 0

export(Array, int) var lifeList #List of ints representing health for each state, 0 reps stage 1
export(Array, Texture) var textureList	#List of image textures
export(float) var trauma_amount = .5
export(float) var decay_rate = .4
export(float) var max_offset = 50

onready var bar = $'Life Bar'
onready var enemy = $Texture
onready var tween = $Tween

signal end_shake
signal start_shake
signal stage_clear
signal enemy_dead
signal damage_taken
signal life_depleted

func _ready():
	enemy.set_texture(textureList.pop_front())
	_start_position = enemy.get_position()
	_trauma = 0.0
	#max_offset


func take_damage(value):
	_start_position = enemy.get_position()
	var currFutureLife = futureLife
	futureLife = currentLife - 1*100
	
	#Animate damage
	tween.interpolate_property(bar, "value", currFutureLife, futureLife, 1, Tween.TRANS_LINEAR, Tween.EASE_OUT) 
	tween.start()
	
	add_trauma(trauma_amount)
	
	if futureLife <= 0:
		emit_signal('life_depleted')
		yield(self, "end_shake")
		emit_signal("stage_clear")
		if not textureList.empty():
			enemy.set_texture(textureList.pop_front())
	else:
		yield(self, "end_shake")
	
	currentLife -= value*100
	emit_signal('damage_taken')


func _on_stage_ready():
	currentLife = lifeList.pop_front()*100
	futureLife = currentLife
	bar.max_value = currentLife
	bar.value = futureLife
	

func get_hp():
	return currentLife
		
		
func add_trauma(amount):
	#print("START SHAKING")
	emit_signal('start_shake')
	shaking = true
	_trauma = min(_trauma + amount, 1)


func _process(delta):
	if _trauma > 0:
		_decay_trauma(delta)
		_apply_shake()
	if _trauma == 0 and shaking:
		shaking = false
		emit_signal('end_shake')
		
		
func _decay_trauma(delta):
	var change = decay_rate * delta
	_trauma = max(_trauma - change, 0)


func _apply_shake():
	var shake = _trauma * _trauma
	var o_x = max_offset * shake * _get_neg_or_pos_scalar()
	var o_y = max_offset * shake * _get_neg_or_pos_scalar()
	enemy.set_position(_start_position + Vector2(o_x, o_y))


func _get_neg_or_pos_scalar():
	return rand_range(-1.0, 1.0)