extends AnimatedSprite2D

const TIME_BETEEN_MOVEMENTS = 0.04

var _time: float

@onready var _viewport_width: float = get_viewport_rect().size.x


func _ready() -> void:
	position.x = _viewport_width / 2


func _process(delta: float) -> void:
	if not visible:
		return
	_time += delta
	if _time >= TIME_BETEEN_MOVEMENTS:
		_on_timer_timeout()
		_time = 0


func _on_timer_timeout() -> void:
	position.x += -3 if (randi() % 10) == 0 else 3
	if position.x <=  _viewport_width / 4.0:
		position.x += 3
	elif position.x >= (_viewport_width / 4.0) * 3:
		position.x -= 3


func _on_visibility_changed() -> void:
	_time = 0
