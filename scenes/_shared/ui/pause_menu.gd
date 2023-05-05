extends Control

@export var show_auto_fire: bool = false

@onready var _pause_label = %PauseLabel as Label
@onready var _give_up_button = %GiveUpButton as Button
@onready var _pause_dialog = $PauseDialog
@onready var _confirm_exit_dialog = $ConfirmExitLevelDialog
@onready var _autofire_checkbox := %AutofireCheckButton as CheckButton
@onready var _vibrate_checkbox := %VibrateCheckButton as CheckButton
@onready var _no_button := %NoButton
@onready var _scene_tree := get_tree()


func _ready() -> void:
	if get_parent() == _scene_tree.root:
		visible = false
		_show_menu(true)


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("pause"):
		if not _scene_tree.paused and Game.is_pause_disabled:
			return
		_scene_tree.paused = not _scene_tree.paused
		_show_menu(_scene_tree.paused)


func _show_menu(make_visible: bool) -> void:
	if make_visible == visible:
		return
	
	visible = make_visible
	if visible:
		_confirm_exit_dialog.visible = false
		_pause_dialog.visible = true
		_autofire_checkbox.visible = show_auto_fire
		_populate_settings()
		_vibrate_checkbox.call_deferred("grab_focus")
		# Hack? This resets its size to the height of its content.
		_pause_dialog.size.y = 0
	else:
		SaveDataManager.save()


func _populate_settings() -> void:
	_autofire_checkbox.set_pressed_no_signal(SaveDataManager.save_data.is_autofire_enabled)
	_vibrate_checkbox.set_pressed_no_signal(SaveDataManager.save_data.is_vibration_enabled)


func _on_day_3_ui_pause_state_changed(is_paused: bool) -> void:
	_show_menu(is_paused)


func _on_vibrate_check_button_toggled(button_pressed: bool) -> void:
	SaveDataManager.save_data.is_vibration_enabled = button_pressed
	if button_pressed:
		Utils.vibrate_joy()


func _on_autofire_check_button_toggled(button_pressed: bool) -> void:
	SaveDataManager.save_data.is_autofire_enabled = button_pressed


func _on_give_up_button_pressed() -> void:
	_pause_dialog.visible = false
	_confirm_exit_dialog.visible = true
	_no_button.call_deferred("grab_focus")


func _on_no_button_pressed() -> void:
	_confirm_exit_dialog.visible = false
	_pause_dialog.visible = true
	_give_up_button.call_deferred("grab_focus")


func _on_yes_button_pressed() -> void:
	SaveDataManager.save()
	print("YOU GAVE UP!!!!")
	# TODO return to title screen
