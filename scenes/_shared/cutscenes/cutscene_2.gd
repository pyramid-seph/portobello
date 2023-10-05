extends Control


signal finished

@export var _autostart: bool


func _ready() -> void:
	if _autostart:
		play()


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("skip_cutscene"):
		get_viewport().set_input_as_handled()
		finish()


func play() -> void:
	_play()


func finish() -> void:
	_internal_stop()


# Override
func _play() -> void:
	_internal_stop()


# Override
func _clean_up() -> void:
	pass


func _internal_stop() -> void:
	_clean_up()
	finished.emit()
