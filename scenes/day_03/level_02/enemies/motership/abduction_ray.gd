extends Node2D

const LINES_POS_1: float = 4.0
const LINES_POS_2: float = 21.0

@export var _color_duration: float = 1.0
@export var _ray_color_1: Color = Color.MAGENTA
@export var _ray_color_2: Color = Color.MAGENTA
@export var _autostart: bool 


const SFX_MOTERSHIP_ABDUCTION_RAY = preload("res://audio/sfx/sfx_motership_abduction_ray.wav")

var _tween: Tween

@onready var _ray := $Ray as Line2D
@onready var _abduction_lines := $AbductionLines as Node2D


func _ready() -> void:
	visible = false
	if _autostart:
		start()


func _exit_tree() -> void:
	SoundManager.stop_sound(SFX_MOTERSHIP_ABDUCTION_RAY)


func start() -> void:
	SoundManager.play_sound(SFX_MOTERSHIP_ABDUCTION_RAY)
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
	SoundManager.stop_sound(SFX_MOTERSHIP_ABDUCTION_RAY)
	visible = false
	if _tween:
		_tween.kill()
	_tween = null
