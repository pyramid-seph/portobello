extends Control


signal closed

const SECTION_STARS: int = 0
const SECTION_HIGH_SCORES: int = 1
const STARS_STRINGS: Array[String] = ["", "*", "**", "***", "****", "*****"]
const UNKNOWN_MINI_GAME: String = "?????"
const UNKNOWN_VALUE: String = "---"

@onready var _is_ready := true
@onready var _record_type_selector := %RecordTypeSelector
@onready var _label_0 := %TwoColLabel0
@onready var _label_1 := %TwoColLabel1
@onready var _label_2 := %TwoColLabel2
@onready var _label_3 := %TwoColLabel3
@onready var _label_4 := %TwoColLabel4
@onready var _label_5 := %TwoColLabel5
@onready var _label_6 := %TwoColLabel6
@onready var _label_7 := %TwoColLabel7
@onready var _label_8 := %TwoColLabel8


func _init() -> void:
	visible = false


func _ready() -> void:
	var selected_index: int = _record_type_selector.current_option_idx 
	_on_record_type_label_current_option_index_changed(selected_index)
	visible = get_parent() == $"/root"


func _get_stars_string(count: int) -> String:
	var clamped_count := clampi(count, 0, STARS_STRINGS.size())
	return STARS_STRINGS[clamped_count]


func _show_stars() -> void:
	var save_data := SaveDataManager.save_data as SaveData
	if save_data.latest_day_completed > 0:
		_label_0.text_1 = "Día 1"
		_label_0.text_2 = _get_stars_string(save_data.stars.day_one)
	else:
		_label_0.text_1 = UNKNOWN_MINI_GAME
		_label_0.text_2 = UNKNOWN_VALUE
	
	if save_data.latest_day_completed > 1:
		_label_1.text_1 = "Día 2"
		_label_1.text_2 = _get_stars_string(save_data.stars.day_two)
	else:
		_label_1.text_1 = UNKNOWN_MINI_GAME
		_label_1.text_2 = UNKNOWN_VALUE
	
	if save_data.latest_day_completed > 2:
		_label_2.text_1 = "Día 3"
		_label_2.text_2 = _get_stars_string(save_data.stars.day_three)
	else:
		_label_2.text_1 = UNKNOWN_MINI_GAME
		_label_2.text_2 = UNKNOWN_VALUE
	
	_label_3.text_1 = ""
	_label_3.text_2 = ""
	_label_4.text_1 = ""
	_label_4.text_2 = ""
	_label_5.text_1 = ""
	_label_5.text_2 = ""
	_label_6.text_1 = ""
	_label_6.text_2 = ""
	_label_7.text_1 = ""
	_label_7.text_2 = ""
	_label_8.text_1 = ""
	_label_8.text_2 = ""


func _show_high_scores() -> void:
	var save_data := SaveDataManager.save_data as SaveData
	
	if save_data.latest_day_completed > 0:
		_label_0.text_1 = "Buffet 1A"
		_label_0.text_2 = str(save_data.high_scores.buff_one_a)
		_label_1.text_1 = "Buffet 1B"
		_label_1.text_2 = str(save_data.high_scores.buff_one_b)
		_label_2.text_1 = "Buffet 1C"
		_label_2.text_2 = str(save_data.high_scores.buff_one_c)
		_label_3.text_1 = "Buffet 1D"
		_label_3.text_2 = str(save_data.high_scores.buff_one_d)
	else:
		_label_0.text_1 = UNKNOWN_MINI_GAME
		_label_0.text_2 = UNKNOWN_VALUE
		_label_1.text_1 = UNKNOWN_MINI_GAME
		_label_1.text_2 = UNKNOWN_VALUE
		_label_2.text_1 = UNKNOWN_MINI_GAME
		_label_2.text_2 = UNKNOWN_VALUE
		_label_3.text_1 = UNKNOWN_MINI_GAME
		_label_3.text_2 = UNKNOWN_VALUE
	
	if save_data.latest_day_completed > 1:
		_label_4.text_1 = "Buffet 2"
		_label_4.text_2 = str(save_data.high_scores.buff_two)
		_label_7.text_1 = "Día 2"
		_label_7.text_2 = str(save_data.high_scores.day_two)
	else:
		_label_4.text_1 = UNKNOWN_MINI_GAME
		_label_4.text_2 = UNKNOWN_VALUE
		_label_7.text_1 = UNKNOWN_MINI_GAME
		_label_7.text_2 = UNKNOWN_VALUE
	
	if save_data.latest_day_completed > 2:
		_label_5.text_1 = "Buffet 3A"
		_label_5.text_2 = str(save_data.high_scores.buff_three_a)
		_label_6.text_1 = "Buffet 3B"
		_label_6.text_2 = str(save_data.high_scores.buff_three_b)
		_label_8.text_1 = "Día 3"
		_label_8.text_2 = str(save_data.high_scores.day_three)
	else:
		_label_5.text_1 = UNKNOWN_MINI_GAME
		_label_5.text_2 = UNKNOWN_VALUE
		_label_6.text_1 = UNKNOWN_MINI_GAME
		_label_6.text_2 = UNKNOWN_VALUE
		_label_8.text_1 = UNKNOWN_MINI_GAME
		_label_8.text_2 = UNKNOWN_VALUE


func _on_record_type_label_current_option_index_changed(value: int) -> void:
	if _is_ready:
		match value:
			SECTION_STARS:
				_show_stars()
			SECTION_HIGH_SCORES:
				_show_high_scores()


func _on_visibility_changed() -> void:
	if not _is_ready:
		return
	
	if visible:
		process_mode = Node.PROCESS_MODE_ALWAYS
		_record_type_selector.current_option_idx = 0
		_record_type_selector.call_deferred("grab_focus")
	else:
		process_mode = Node.PROCESS_MODE_DISABLED


func _on_go_back_btn_pressed() -> void:
	visible = false
	closed.emit()
