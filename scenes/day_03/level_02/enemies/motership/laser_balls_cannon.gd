@tool
class_name LaserBallsCannon
extends Node2D


signal discharged
signal target_detected

@export_color_no_alpha var _stand_by_color := Color.MAGENTA:
	set(value):
		_stand_by_color = value
		_on_stand_by_color_set()
@export_color_no_alpha var _charging_color := Color.MAGENTA
@export var _charging_duration_sec: float = 1.0
@export_color_no_alpha var _detecting_color := Color.MAGENTA
@export var _detecting_duration_sec: float = 1.0
@export_color_no_alpha var _laser_ext_color_1 := Color.MAGENTA
@export_color_no_alpha var _laser_ext_color_2 := Color.MAGENTA
@export_color_no_alpha var _laser_int_color_1 := Color.MAGENTA
@export_color_no_alpha var _laser_int_color_2 := Color.MAGENTA
@export var _laser_duration_sec: float = 1.0

var target: Node2D

var _tween_charge: Tween
var _tween_fire: Tween

@onready var _timer := $Timer as Timer
@onready var _left_ball := $LeftBall
@onready var _right_ball := $RightBall
@onready var _laser := $Laser as Area2D
@onready var _outer_color := $Laser/OuterColor as Line2D
@onready var _inner_color := $Laser/InnerColor as Line2D
@onready var _state_machine := $StateMachine as LaserBallsCannonStateMachine
@onready var _is_ready: bool = true


func _ready() -> void:
	_on_stand_by_color_set()


func is_discharged() -> bool:
	return _state_machine.is_in_state("Discharged")


func charge() -> void:
	if not Engine.is_editor_hint():
		_state_machine.charge()


func deactivate() -> void:
	_state_machine.deactivate()


func fire() -> void:
	if not Engine.is_editor_hint():
		_state_machine.fire()


func _change_balls_color(color: Color) -> void:
	_left_ball.color = color
	_right_ball.color = color


func _set_laser_visibility(make_visible: bool) -> void:
	_outer_color.visible = make_visible
	_inner_color.visible = make_visible


func _on_stand_by_color_set() -> void:
	if Engine.is_editor_hint() and _is_ready:
		_change_balls_color(_stand_by_color)


func _on_laser_area_entered(area: Area2D) -> void:
	target_detected.emit()
