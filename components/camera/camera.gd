extends Camera2D

var _start_position = 0
var _trauma = 0

export(float) var decay_rate = .4
export(float) var max_offset = 50

func _ready():
	_start_position = get_position()

func add_trauma(amount):
	_trauma = min(_trauma + amount, 1)
	
func set_trauma(amount):
	_trauma = amount
	
func _process(delta):
	if _trauma > 0:
		_decay_trauma(delta)
		_apply_shake()
		
func _decay_trauma(delta):
	var change = decay_rate * delta
	_trauma = max(_trauma - change, 0)

func _apply_shake():
	var shake = _trauma * _trauma
	var o_x = max_offset * shake * _get_neg_or_pos_scalar()
	var o_y = max_offset * shake * _get_neg_or_pos_scalar()
	set_offset(Vector2(o_x, o_y))

func _get_neg_or_pos_scalar():
	return rand_range(-1.0, 1.0)