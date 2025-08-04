class_name DialogueBox
extends PanelContainer

signal started
signal finished

@export var dialogue: Array[DialogueLine]:
	set(value):
		dialogue = value
		if is_node_ready():
			stop()
@export var _autostart: bool

var _is_playing: bool

@onready var _timer := $Timer as Timer
@onready var _label := $Label as Label


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
	visible = true
	for line: DialogueLine in dialogue:
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
	Utils.safe_disconnect_all(_timer.timeout)
	_reset_ui()
	_is_playing = false


func _reset_ui() -> void:
	visible = false
	_label.text = ""
