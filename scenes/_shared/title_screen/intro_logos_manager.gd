@tool
class_name IntroLogosManager
extends Control

signal started
signal finished

const LOGO_IDX_BEFORE_FIRST: int = -1

@export_range(0.1, 1.0, 0.01, "or_greater")
var _first_logo_delay_sec: float = 1.0
@export_range(0.1, 1.0, 0.01, "or_greater")
var _delay_between_logos_sec: float = 1.0
@export_range(0.1, 1.0, 0.01, "or_greater")
var _finish_delay_sec: float = 1.0
@export var _background_color: Color:
	set(value):
		_background_color = value
		_on_background_color_set()
@export var _autostart: bool

var _curr_logo_idx: int = LOGO_IDX_BEFORE_FIRST
var _intro_logos: Array[IntroLogo] = []

@onready var _delay_timer: Timer = $DelayTimer
@onready var _bg_color_rect: ColorRect = $BackgroundColorRect


func _ready() -> void:
	_on_background_color_set()
	if not Engine.is_editor_hint():
		_setup()
		_reset()
		if _autostart:
			play()


func play() -> void:
	_reset()
	show()
	_advance()


func _setup() -> void:
	for item: Node in get_children():
		var intro_logo := item as IntroLogo
		if intro_logo:
			_intro_logos.append(intro_logo)
			intro_logo.finished.connect(_on_intro_logo_finished)


func _reset() -> void:
	_curr_logo_idx = LOGO_IDX_BEFORE_FIRST
	_delay_timer.stop()
	for item: IntroLogo in _intro_logos:
		item.reset()
	hide()


func _is_invalid_curr_logo_idx() -> bool:
	return _curr_logo_idx <= LOGO_IDX_BEFORE_FIRST or \
			_curr_logo_idx >= _get_logos_count()


func _advance() -> void:
	var curr_intro_logo: IntroLogo = _get_curr_intro_logo()
	if curr_intro_logo:
		curr_intro_logo.reset()
	
	_curr_logo_idx += 1
	if _is_invalid_curr_logo_idx():
		_delay_timer.start(_finish_delay_sec)
	elif _curr_logo_idx > 0:
		_delay_timer.start(_delay_between_logos_sec)
	else:
		_delay_timer.start(_first_logo_delay_sec)
		started.emit()


func _play_curr_intro_logo() -> void:
	var curr_intro_logo: IntroLogo = _get_curr_intro_logo()
	if curr_intro_logo:
		curr_intro_logo.play()


func _get_logos_count() -> int:
	return _intro_logos.size()


func _get_curr_intro_logo() -> IntroLogo:
	if _is_invalid_curr_logo_idx():
		return null
	
	return _intro_logos[_curr_logo_idx]


func _on_background_color_set() -> void:
	if is_node_ready():
		_bg_color_rect.color = _background_color


func _on_intro_logo_finished() -> void:
	_advance()


func _on_delay_timer_timeout() -> void:
	if _is_invalid_curr_logo_idx():
		_reset()
		hide()
		finished.emit()
	else:
		_play_curr_intro_logo()
