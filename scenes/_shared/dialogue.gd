class_name Dialogue
extends Node

signal started
signal finished

@export var _dialogue: Array[DialogueLine]:
	set(value):
		_dialogue = value
		if _is_ready:
			stop()
@export var _autostart: bool

var _is_playing: bool

@onready var _is_ready: bool = true
@onready var _timer := $Timer as Timer
@onready var _label := $DialogueBox/Label as Label
@onready var _box := $DialogueBox


func _ready() -> void:
	stop()
	if _autostart:
		start()


func is_playing() -> bool:
	return _is_playing


func start() -> void:
	stop()
	_is_playing = true
	started.emit()
	_box.visible = true
	for line in _dialogue:
		if line.delay_sec > 0:
			_timer.start(line.delay_sec)
			await _timer.timeout
		_label.text = line.text
		if line.duration_sec > 0:
			_timer.start(line.duration_sec)
			await _timer.timeout
		_label.text = ""
	_reset_ui()
	_is_playing = false
	finished.emit()
	


func stop() -> void:
	_timer.stop()
	_reset_ui()
	_is_playing = false


func _reset_ui() -> void:
	_box.visible = false
	_label.text = ""
