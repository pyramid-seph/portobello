extends Control


signal finished

@export var _autostart: bool

var _old_touch_controller_mode: TouchControllerManager.Mode

func _ready() -> void:
	TouchControllerManager.mode = TouchControllerManager.Mode.CUTSCENE
	if _autostart:
		play()


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("skip_cutscene"):
		get_viewport().set_input_as_handled()
		finish()


func play() -> void:
	_old_touch_controller_mode = TouchControllerManager.mode
	TouchControllerManager.mode = TouchControllerManager.Mode.CUTSCENE
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
	TouchControllerManager.mode = _old_touch_controller_mode
	_clean_up()
	finished.emit()
