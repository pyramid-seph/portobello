extends Control


signal closed
signal dangerous_option_focused
signal dangerous_option_unfocused

const IDX_YES: int = 0
const IDX_NO: int = 1

@onready var _is_ready := true
@onready var _autofire_selector := %AutofireSelector
@onready var _vibration_selector := %VibrationSelector
@onready var _erase_data_btn := %EraseDataBtn
@onready var _confirm_erase_data_dialog := %ConfirmEraseDataDialog
@onready var _erased_data_dialog := %ErasedDataDialog


func _init() -> void:
	visible = false


func _ready() -> void:
	visible = get_parent() == $"/root"


func _get_option_idx(is_feature_enabled: bool) -> int:
	return IDX_YES if is_feature_enabled else IDX_NO


func _is_feature_enabled(selector) -> bool:
	return selector.current_option_idx == IDX_YES


func _load_data() -> void:
	var save_data := SaveDataManager.save_data as SaveData
	var is_autofire_enabled: bool = save_data.is_autofire_enabled
	var is_vibration_enabled: bool = save_data.is_vibration_enabled
	_autofire_selector.current_option_idx = _get_option_idx(is_autofire_enabled)
	_vibration_selector.current_option_idx = _get_option_idx(is_vibration_enabled)


func _save_data() -> void:
	var is_autofire_enabled: bool = _is_feature_enabled(_autofire_selector)
	var is_vibration_enabled: bool = _is_feature_enabled(_vibration_selector)
	SaveDataManager.save_data.is_autofire_enabled = is_autofire_enabled
	SaveDataManager.save_data.is_vibration_enabled = is_vibration_enabled
	SaveDataManager.save()


func _on_visibility_changed() -> void:
	if not _is_ready:
		return
	
	if visible:
		process_mode = Node.PROCESS_MODE_ALWAYS
		_load_data()
		_vibration_selector.call_deferred("grab_focus")
	else:
		process_mode = Node.PROCESS_MODE_DISABLED


func _on_erase_data_btn_pressed() -> void:
	_confirm_erase_data_dialog.visible = true


func _on_confirm_erase_data_dialog_positive_btn_pressed() -> void:
	SaveDataManager.reset_save_data()
	_erased_data_dialog.visible = true
	_load_data()


func _on_confirm_erase_data_dialog_negative_btn_pressed() -> void:
	_erase_data_btn.call_deferred("grab_focus")


func _on_erased_data_dialog_positive_btn_pressed() -> void:
	_erase_data_btn.call_deferred("grab_focus")


func _on_erase_data_btn_focus_entered() -> void:
	dangerous_option_focused.emit()


func _on_erase_data_btn_focus_exited() -> void:
	if not _confirm_erase_data_dialog.visible:
		dangerous_option_unfocused.emit()


func _on_go_back_btn_pressed() -> void:
	visible = false
	_save_data()
	closed.emit()
