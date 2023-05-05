extends Node2D

const LINES_POS_1: float = 4.0
const LINES_POS_2: float = 21.0

@export var _color_duration: float = 1.0
@export_color_no_alpha var _ray_color_1: Color
@export_color_no_alpha var _ray_color_2: Color
@export var _autostart: bool 

var _tween: Tween

@onready var _ray := $Ray as Line2D
@onready var _abduction_lines := $AbductionLines as Node2D


func _ready() -> void:
	visible = false
	if _autostart:
		start()


func start() -> void:
	visible = true
	if _tween:
		_tween.kill()
	_tween = create_tween()
	_tween.set_loops()
	_tween.tween_callback(func():
		_ray.modulate = _ray_color_1
		_abduction_lines.position.y = LINES_POS_1
	)
	_tween.tween_interval(_color_duration)
	_tween.tween_callback(func():
		_ray.modulate = _ray_color_2
		_abduction_lines.position.y = LINES_POS_2
	)
	_tween.tween_interval(_color_duration)


func stop() -> void:
	visible = false
	if _tween:
		_tween.kill()
	_tween = null
