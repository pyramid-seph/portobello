extends Control


signal finished


@export var _skip_sound = preload("res://audio/ui/ui_pressed.wav")
@export var _autostart: bool


func _ready() -> void:
	if _autostart:
		play()


func _exit_tree() -> void:
	SoundManager.stop_music()


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("skip_cutscene"):
		SoundManager.play_ui_sound(_skip_sound)
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
