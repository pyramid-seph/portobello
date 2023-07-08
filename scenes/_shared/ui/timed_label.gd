extends Label


signal finished

@export var _duration_sec: float = 1

@onready var _timer := $Timer as Timer


func _ready() -> void:
	visible = false


func start() -> void:
	visible = true
	_timer.start(_duration_sec)
	await _timer.timeout
	finished.emit()
	visible = false
