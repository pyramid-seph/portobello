extends Control

@onready var pause_label = %PauseLabel
@onready var give_up_label = %GiveUpLabel
@onready var pause_dialog = $PauseDialog
@onready var autofire_checkbox := %AutofireCheckbox as CheckButton
@onready var vibrate_checkbox := %VibrateCheckbox as CheckButton

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
		autofire_checkbox.visible = show_auto_fire
		_populate_settings()
		# Hack? This resets its size to the height of its content.
		pause_dialog.size.y = 0
	else:
		SaveDataManager.save()


func _populate_settings() -> void:
	autofire_checkbox.set_pressed_no_signal(SaveDataManager.save_data.is_autofire_enabled)
	vibrate_checkbox.set_pressed_no_signal(SaveDataManager.save_data.is_vibration_enabled)


func _on_vibrate_checkbox_toggled(button_pressed: bool) -> void:
	SaveDataManager.save_data.is_vibration_enabled = button_pressed
	if button_pressed:
		Utils.vibrate_joy()
	print(str(button_pressed))


func _on_autofire_checkbox_toggled(button_pressed: bool) -> void:
	SaveDataManager.save_data.is_autofire_enabled = button_pressed
	print(str(button_pressed))


func _on_give_up_label_pressed() -> void:
	SaveDataManager.save()
	print("YOU HAVE GIVE UP!!")


func _on_day_3_ui_pause_state_changed(new_state: bool) -> void:
	show_menu(new_state)
