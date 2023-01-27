extends Control

@onready var pause_label = %PauseLabel
@onready var give_up_button = %GiveUpButton
@onready var pause_dialog = $PauseDialog
@onready var confirm_exit_dialog = $ConfirmExitLevelDialog
@onready var autofire_checkbox := %AutofireCheckButton as CheckButton
@onready var vibrate_checkbox := %VibrateCheckButton as CheckButton
@onready var no_button := %NoButton

@export var show_auto_fire: bool = false


func _ready() -> void:
	if get_parent() == get_tree().root:
		visible = false
		show_menu(true)


func show_menu(make_visible: bool) -> void:
	if make_visible == visible:
		return
	
	visible = make_visible
	if visible:
		confirm_exit_dialog.visible = false
		pause_dialog.visible = true
		autofire_checkbox.visible = show_auto_fire
		_populate_settings()
		vibrate_checkbox.call_deferred("grab_focus")
		# Hack? This resets its size to the height of its content.
		pause_dialog.size.y = 0
	else:
		SaveDataManager.save()


func _populate_settings() -> void:
	autofire_checkbox.set_pressed_no_signal(SaveDataManager.save_data.is_autofire_enabled)
	vibrate_checkbox.set_pressed_no_signal(SaveDataManager.save_data.is_vibration_enabled)


func _on_day_3_ui_pause_state_changed(is_paused: bool) -> void:
	show_menu(is_paused)


func _on_vibrate_check_button_toggled(button_pressed: bool) -> void:
	SaveDataManager.save_data.is_vibration_enabled = button_pressed
	if button_pressed:
		Utils.vibrate_joy()


func _on_autofire_check_button_toggled(button_pressed: bool) -> void:
	SaveDataManager.save_data.is_autofire_enabled = button_pressed


func _on_give_up_button_pressed() -> void:
	pause_dialog.visible = false
	confirm_exit_dialog.visible = true
	no_button.call_deferred("grab_focus")


func _on_no_button_pressed() -> void:
	confirm_exit_dialog.visible = false
	pause_dialog.visible = true
	give_up_button.call_deferred("grab_focus")


func _on_yes_button_pressed() -> void:
	SaveDataManager.save()
	print("YOU GAVE UP!!!!")
	# TODO return to title screen
