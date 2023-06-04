extends Node2D


signal finished

@export var _autostart: bool


func _ready() -> void:
	if _autostart:
		play()


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("fire"):
		_internal_stop()


func play() -> void:
	_play()


# Override
func _play() -> void:
	_internal_stop()


# Override
func _clean_up() -> void:
	pass


func _internal_stop() -> void:
	_clean_up()
	finished.emit()
