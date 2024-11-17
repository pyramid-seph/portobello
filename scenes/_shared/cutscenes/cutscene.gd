extends Control


signal finished


@export var _autostart: bool

var _is_playing: bool
var _old_touch_controller_mode: TouchControllerManager.Mode


func _ready() -> void:
	set_process_unhandled_input(false)
	TouchControllerManager.mode = TouchControllerManager.Mode.CUTSCENE
	if _autostart:
		play()


func _exit_tree() -> void:
	SoundManager.stop_music()


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("skip_cutscene"):
		get_viewport().set_input_as_handled()
		finish()


func play() -> void:
	if _is_playing:
		return
	
	_is_playing = true
	set_process_unhandled_input(true)
	_old_touch_controller_mode = TouchControllerManager.mode
	TouchControllerManager.mode = TouchControllerManager.Mode.CUTSCENE
	_play()


func finish() -> void:
	set_process_unhandled_input(false)
	_internal_stop()
	_is_playing = false


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
