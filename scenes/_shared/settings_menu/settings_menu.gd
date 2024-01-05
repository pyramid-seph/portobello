extends Control


signal closed
signal dangerous_option_focused
signal dangerous_option_unfocused

const IDX_YES: int = 0
const IDX_NO: int = 1
const LANGUAGE_OPTIONS := [
	{
		"label": "MENU_SETTINGS_LANGUAGE_OPTION_EN",
		"value": "en",
	},
	{
		"label": "MENU_SETTINGS_LANGUAGE_OPTION_ES",
		"value": "es",
	},
]

@onready var _is_ready := true
@onready var _autofire_selector := %AutofireSelector
@onready var _vibration_selector := %VibrationSelector
@onready var _audio_selector: HSelector = %AudioSelector
@onready var _erase_data_btn := %EraseDataBtn
@onready var _confirm_erase_data_dialog := %ConfirmEraseDataDialog
@onready var _erased_data_dialog := %ErasedDataDialog
@onready var _language_selector: HSelector = %LanguageSelector
@onready var _black_screen: ColorRect = $BlackScreen


func _init() -> void:
	visible = false


func _ready() -> void:
	visible = get_parent() == $"/root"
	_language_selector.set_options(LANGUAGE_OPTIONS)


func _get_yes_no_option_idx(is_feature_enabled: bool) -> int:
	return IDX_YES if is_feature_enabled else IDX_NO


func _get_language_option_idx() -> int:
	var selected_lang_idx: int = Utils.index_of(LANGUAGE_OPTIONS, func(item):
		return item.value == SaveDataManager.save_data.language
	)
	return maxi(selected_lang_idx, 0)


func _set_locale(locale: String):
	TranslationServer.set_locale(locale)


func _is_feature_enabled(selector) -> bool:
	return selector.current_option_idx == IDX_YES


func _load_data() -> void:
	var save_data := SaveDataManager.save_data as SaveData
	var is_autofire_enabled: bool = save_data.is_autofire_enabled
	var is_vibration_enabled: bool = save_data.is_vibration_enabled
	var is_audio_enabled: bool = save_data.is_audio_enabled
	_autofire_selector.current_option_idx = _get_yes_no_option_idx(is_autofire_enabled)
	_vibration_selector.current_option_idx = _get_yes_no_option_idx(is_vibration_enabled)
	_audio_selector.current_option_idx = _get_yes_no_option_idx(is_audio_enabled)
	_language_selector.current_option_idx = _get_language_option_idx()


func _save_data() -> void:
	var is_autofire_enabled: bool = _is_feature_enabled(_autofire_selector)
	var is_vibration_enabled: bool = _is_feature_enabled(_vibration_selector)
	var is_audio_enabled: bool = _is_feature_enabled(_audio_selector)
	var selected_lang_index: int = _language_selector.current_option_idx
	var selected_language: String = LANGUAGE_OPTIONS[selected_lang_index].value 
	SaveDataManager.save_data.is_autofire_enabled = is_autofire_enabled
	SaveDataManager.save_data.is_vibration_enabled = is_vibration_enabled
	SaveDataManager.save_data.is_audio_enabled = is_audio_enabled
	SaveDataManager.save_data.language = selected_language
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
	_set_locale(SaveDataManager.save_data.language)
	Utils.unmute()
	Game.is_cold_boot = true
	Game.start(Game.Minigame.TITLE_SCREEN, true)


func _on_erase_data_btn_focus_entered() -> void:
	dangerous_option_focused.emit()


func _on_erase_data_btn_focus_exited() -> void:
	if not _confirm_erase_data_dialog.visible:
		dangerous_option_unfocused.emit()


func _on_go_back_btn_pressed() -> void:
	visible = false
	_save_data()
	closed.emit()


func _on_vibration_selector_current_option_index_changed(value: int) -> void:
	if value == IDX_YES:
		Utils.vibrate_joy_demo()


func _on_audio_selector_current_option_index_changed(value: int) -> void:
	if value == IDX_YES:
		Utils.unmute()
	else:
		Utils.mute()


func _on_language_selector_current_option_index_changed(index: int) -> void:
	_set_locale(LANGUAGE_OPTIONS[index].value)


func _on_erased_data_dialog_visibility_changed() -> void:
	_black_screen.visible = _erased_data_dialog.visible
