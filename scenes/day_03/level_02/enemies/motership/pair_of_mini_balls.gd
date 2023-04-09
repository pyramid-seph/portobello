@tool
extends Node2D


@export_color_no_alpha var _color_one := Color.MAGENTA:
	set(value):
		_color_one = value
		if _is_ready:
			_change_color(value)
@export_color_no_alpha var _color_two := Color.MAGENTA
@export_color_no_alpha var _color_three := Color.MAGENTA
@export var _time_between_colors_sec: float = 1.0

var _tween: Tween

@onready var _left_ball := $LeftMotershipBallMini
@onready var _right_ball := $RightMotershipBallMini
@onready var _is_ready: bool = true


func _ready() -> void:
	if Engine.is_editor_hint():
		_change_color(_color_one)
	else:
		_animate()


func _change_color(color: Color) -> void:
	_left_ball.color = color
	_right_ball.color = color


func _animate() -> void:
	if _tween:
		_tween.kill()

	_tween = create_tween()
	_tween.set_loops()
	_tween.tween_callback(_change_color.bind(_color_one))
	_tween.tween_interval(_time_between_colors_sec)
	_tween.tween_callback(_change_color.bind(_color_two))
	_tween.tween_interval(_time_between_colors_sec)
	_tween.tween_callback(_change_color.bind(_color_three))
	_tween.tween_interval(_time_between_colors_sec)
