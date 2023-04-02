extends ColorRect


signal finished


@export var duration_sec: float = 1.0
@export_color_no_alpha var color_1: Color = Color.MAGENTA
@export_color_no_alpha var color_2: Color = Color.MAGENTA

var _tween: Tween

@onready var _timer := $Timer as Timer


func start(time_sec: float = duration_sec) -> void:
	visible = true
	color = color_1
	
	if _tween:
		_timer.stop()
		_tween.kill()
	_tween = create_tween()
	_tween.set_loops()
	_tween.tween_callback(func(): color = color_2).set_delay(Utils.FRAME_TIME)
	_tween.tween_callback(func(): color = color_1).set_delay(Utils.FRAME_TIME)
	_timer.start(time_sec)
	_timer.timeout.connect(func():
		visible = false
		finished.emit()
		_tween.kill()
		_tween = null
	)
