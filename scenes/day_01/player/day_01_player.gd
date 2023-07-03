extends Node2D

signal ate
signal crashed

const INITIAL_DIR := Vector2i.RIGHT
const PIXELS_PER_STEP: int = 7

@export var inverted_controls: bool
@export var pace_sec: float = 0.25

var stop_moving: bool:
	set(value):
		stop_moving = value
		_elapsed_time_sec = 0.0

var _curr_dir: Vector2i = INITIAL_DIR
var _has_crashed: bool:
	set(value):
		_has_crashed = value
		_elapsed_time_sec = 0.0
var _elapsed_time_sec: float

@onready var _is_ready: bool = true
@onready var _detector := $Head/Area2D as Area2D
@onready var _head := $Head as AnimatedSprite2D


func _process(delta: float) -> void:
	if _has_crashed or stop_moving:
		return
	
	_update_direction()
	
	_elapsed_time_sec += delta
	if _elapsed_time_sec >= pace_sec:
		_elapsed_time_sec = 0.0
		_check_collisions()


func reset() -> void:
	_elapsed_time_sec = 0.0
	_curr_dir = INITIAL_DIR


func _update_direction() -> void:
	var candidate: Vector2i
	if Input.is_action_pressed("move_right"):
		candidate = Vector2i.LEFT if inverted_controls else Vector2i.RIGHT
	elif Input.is_action_pressed("move_left"):
		candidate = Vector2i.RIGHT if inverted_controls else Vector2i.LEFT
	elif  Input.is_action_pressed("move_down"):
		candidate = Vector2i.UP if inverted_controls else Vector2i.DOWN
	elif  Input.is_action_pressed("move_up"):
		candidate = Vector2i.DOWN if inverted_controls else Vector2i.UP
	
	if candidate != Vector2i.ZERO and candidate + _curr_dir != Vector2i.ZERO:
		_curr_dir = candidate
	

func _update_head_position() -> void:
	position += Vector2(_curr_dir * PIXELS_PER_STEP)


func _update_head_rotation() -> void:
	match _curr_dir:
		Vector2i.DOWN:
			rotation_degrees = 90
		Vector2i.UP:
			rotation_degrees = 270
		Vector2i.RIGHT:
			rotation_degrees = 0
		Vector2i.LEFT:
			rotation_degrees = 180


func _check_collisions() -> void:
	# Check if bucho crashes with furniture, wall or himself
	# If not check if he ate a treat
	# if he does not crash, update position
	# if he crashes, do not move the head and firts body part, and change his face to its death face
	_update_head_position()
	_update_head_rotation()
	# TODO ensure animation happens at pace_sec
	
