extends Control


signal finished

const SfxSkip: AudioStream = preload("res://audio/ui/kenney_interface_sounds/select_002.ogg")
const SkipIndicatorScene = preload("res://scenes/_shared/cutscenes/skip_indicator.tscn")

@export var _autostart: bool

var _is_playing: bool
var _old_touch_controller_mode: TouchControllerManager.Mode
var _long_press_skip_cutscene: LongPressAction = LongPressAction.new(
		&"skip_cutscene", 1.0, LongPressAction.CheckMode.ON_PRESS)
var _skip_indicator: SkipIndicator


func _ready() -> void:
	set_process(false)
	TouchControllerManager.mode = TouchControllerManager.Mode.CUTSCENE
	
	_skip_indicator = SkipIndicatorScene.instantiate()
	add_child(_skip_indicator)
	_skip_indicator.reset_size()
	_skip_indicator.hide()
	
	_long_press_skip_cutscene.disabled = true
	_long_press_skip_cutscene.viewport = get_viewport()
	_long_press_skip_cutscene.started.connect(
			_on_long_press_skip_cutscene_started)
	_long_press_skip_cutscene.canceled.connect(
			_on_long_press_skip_cutscene_canceled)
	_long_press_skip_cutscene.completed.connect(
			_on_long_press_skip_cutscene_completed)
	
	if _autostart:
		play()


func _exit_tree() -> void:
	SoundManager.stop_music()


func _process(delta: float) -> void:
	_long_press_skip_cutscene.update(delta)
	_skip_indicator.set_progress(_long_press_skip_cutscene.get_progress())


func _notification(what: int) -> void:
	if is_node_ready() and what == NOTIFICATION_TRANSLATION_CHANGED:
		_skip_indicator.reset_size()


func play() -> void:
	if _is_playing:
		return
	
	_is_playing = true
	set_process(true)
	_skip_indicator.hide()
	_long_press_skip_cutscene.disabled = false
	_old_touch_controller_mode = TouchControllerManager.mode
	TouchControllerManager.mode = TouchControllerManager.Mode.CUTSCENE
	_play()


func finish() -> void:
	set_process(false)
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
	_long_press_skip_cutscene.disabled = true
	_skip_indicator.hide()
	_clean_up()
	finished.emit()


func _on_long_press_skip_cutscene_started() -> void:
	_skip_indicator.show()


func _on_long_press_skip_cutscene_canceled() -> void:
	_skip_indicator.hide()


func _on_long_press_skip_cutscene_completed() -> void:
	SoundManager.play_sound(SfxSkip)
	finish()

