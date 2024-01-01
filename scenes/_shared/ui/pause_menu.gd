extends Control


const IDX_YES: int = 0
const IDX_NO: int = 1

@export var pause_menu_shown_sound: AudioStream
@export var show_auto_fire: bool = false

var enabled := true:
	set(value):
		enabled = value
		_on_enabled_set()

@onready var _give_up_button := %GiveUpButton as Button
@onready var _pause_dialog := $PauseDialog
@onready var _confirm_exit_dialog := $ConfirmExitLevelDialog
@onready var _autofire_selector := %AutofireSelector as HSelector
@onready var _vibration_selector := %VibrationSelector as HSelector
@onready var _scene_tree := get_tree() as SceneTree
@onready var _is_ready := true


func _ready() -> void:
	_on_enabled_set()
	if get_parent() == _scene_tree.root:
		visible = false
		_pause_game(true)


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("pause") and enabled:
		get_viewport().set_input_as_handled()
		_pause_game(!_scene_tree.paused)
		if _scene_tree.paused:
			SoundManager.play_ui_sound(pause_menu_shown_sound)


func _pause_game(pause: bool) -> void:
	if pause == _scene_tree.paused or not enabled:
		return
	
	_scene_tree.paused = pause
	visible = pause
	if pause:
		_confirm_exit_dialog.visible = false
		_pause_dialog.visible = true
		_autofire_selector.visible = show_auto_fire
		_load_settings()
		_vibration_selector.call_deferred("grab_focus")
		# Hack? This resets its size to the height of its content.
		_pause_dialog.size.y = 0
	else:
		_save_settings()


func _get_option_idx(is_feature_enabled: bool) -> int:
	return IDX_YES if is_feature_enabled else IDX_NO


func _is_feature_enabled(selector) -> bool:
	return selector.current_option_idx == IDX_YES


func _load_settings() -> void:
	var save_data := SaveDataManager.save_data as SaveData
	var is_autofire_enabled: bool = save_data.is_autofire_enabled
	var is_vibration_enabled: bool = save_data.is_vibration_enabled
	_autofire_selector.current_option_idx = _get_option_idx(is_autofire_enabled)
	_vibration_selector.current_option_idx = _get_option_idx(is_vibration_enabled)


func _save_settings() -> void:
	var is_autofire_enabled: bool = _is_feature_enabled(_autofire_selector)
	var is_vibration_enabled: bool = _is_feature_enabled(_vibration_selector)
	SaveDataManager.save_data.is_autofire_enabled = is_autofire_enabled
	SaveDataManager.save_data.is_vibration_enabled = is_vibration_enabled
	SaveDataManager.save()


func _on_enabled_set() -> void:
	if _is_ready and not enabled:
		_pause_game(false)


func _on_vibration_selector_current_option_index_changed(value: int) -> void:
	if value == IDX_YES:
		Utils.vibrate_joy_demo()


func _on_give_up_button_pressed() -> void:
	_pause_dialog.visible = false
	_confirm_exit_dialog.visible = true


func _on_continue_button_pressed() -> void:
	_pause_game(false)


func _on_confirm_exit_level_dialog_negative_btn_pressed() -> void:
	_confirm_exit_dialog.visible = false
	_pause_dialog.visible = true
	_give_up_button.call_deferred("grab_focus")


func _on_confirm_exit_level_dialog_positive_btn_pressed() -> void:
	_save_settings()
	_scene_tree.paused = false
	Game.start(Game.Minigame.TITLE_SCREEN)
