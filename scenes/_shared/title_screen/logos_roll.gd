extends Control

signal rolled


@export var _logos_roll_duration_sec: float = 1.0

@onready var _timer := $Timer as Timer


func start() -> void:
	visible = true
	_timer.start(_logos_roll_duration_sec)


func _on_timer_timeout() -> void:
	rolled.emit()
