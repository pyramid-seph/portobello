@tool
class_name HSelector
extends PanelContainer


signal selected(value)
signal current_option_index_changed(index: int)

const SELECTED_NONE: int = -1
const DISABLED_ALPHA: float = 0.38

@export var selector_text: String:
	set(value):
		selector_text = value
		_on_selector_text_set()
@export var _options: Array:
	set(value):
		_options = value
		_on_options_set()
@export var loop_options: bool = true:
	set(value):
		loop_options = value
		_on_loop_options_set()
@export var numbered_list: bool:
	set(value):
		numbered_list = value
		_on_numbered_list_set()
@export var release_focus_on_selection: bool
@export var focus_color: Color = Color.MAGENTA:
	set(value):
		focus_color = value
		_on_focus_color_set()
@export var text_font: Font:
	set(value):
		text_font = value
		_on_text_font_set()
@export var text_color: Color = Color.BLACK:
	set(value):
		text_color = value
		_on_text_color_set()
@export var text_size: int = 16:
	set(value):
		text_size = value
		_on_text_size_set()

var current_option_idx: int = SELECTED_NONE:
	set(value):
		current_option_idx = clampi(value, SELECTED_NONE, _options.size() - 1)
		_on_current_option_idx_set()

var _option_disabled_state: Array[bool]

@onready var _name_label: Label = %NameLabel
@onready var _prev_option_label: Label = %PrevOptionLabel
@onready var _option_label : Label = %OptionLabel
@onready var _next_option_label: Label = %NextOptionLabel
@onready var _labels: Array = $LabelContainer.get_children()


func _ready() -> void:
	_on_options_set()
	_on_current_option_idx_set()
	_on_focus_color_set()
	_on_text_font_set()
	_on_text_color_set()
	_on_text_size_set()
	_update_bg_color()


func _gui_input(event: InputEvent) -> void:
	if Engine.is_editor_hint():
		return
	
	if event.is_action_pressed("ui_accept") and current_option_idx > SELECTED_NONE:
		if not is_option_disabled(current_option_idx):
			if release_focus_on_selection:
				release_focus()
			selected.emit(get_value_for_option(current_option_idx))
		accept_event()
	if event.is_action_pressed("ui_left"):
		_previous_option()
		accept_event()
	if event.is_action_pressed("ui_right"):
		_next_option()
		accept_event()


func _notification(what: int) -> void:
	if what == NOTIFICATION_TRANSLATION_CHANGED:
		_on_current_option_idx_set()


func set_options(arr: Array) -> void:
	_options = arr


func is_option_disabled(idx: int) -> bool:
	if idx > -1 and idx < _options.size():
		return _option_disabled_state[idx]
	return false


func set_option_disabled(idx: int, disabled: bool) -> void:
	if idx > -1 and idx < _options.size():
		_option_disabled_state[idx] = disabled
		if current_option_idx == idx:
			_on_current_option_idx_set()


func get_value_for_option(idx: int):
	var option = _options[idx]
	if typeof(option) == TYPE_DICTIONARY:
		return option.value
	else:
		return idx


func get_options_count() -> int:
	return _options.size()


func _emit_current_option_index_changed() -> void:
	if not Engine.is_editor_hint():
		current_option_index_changed.emit(current_option_idx)


func _previous_option() -> void:
	var old_current_option_idx: int = current_option_idx
	if _options.is_empty():
		current_option_idx = SELECTED_NONE
	elif loop_options:
		current_option_idx = wrapi(current_option_idx - 1, 0, _options.size())
	else:
		current_option_idx = maxi(current_option_idx - 1, 0)
	if old_current_option_idx != current_option_idx:
		_emit_current_option_index_changed()


func _next_option() -> void:
	var old_current_option_idx: int = current_option_idx
	if _options.is_empty():
		current_option_idx = SELECTED_NONE
	elif loop_options:
		current_option_idx = wrapi(current_option_idx + 1, 0, _options.size())
	else:
		current_option_idx = mini(_options.size() - 1, current_option_idx + 1)
	if old_current_option_idx != current_option_idx:
		_emit_current_option_index_changed()


func _update_bg_color() -> void:
	var curr_theme_style_box := get_theme_stylebox(&"panel")
	curr_theme_style_box.bg_color = \
			focus_color if has_focus() else Color.TRANSPARENT


func _get_label_for_option(idx: int) -> String:
	var option = _options[idx]
	var option_msg: String = ""
	if typeof(option) == TYPE_DICTIONARY:
		option_msg = option.label
	elif option:
		option_msg = option
	var number: String = ("%s. " % (idx + 1)) if numbered_list else ""
	return number + tr(option_msg)


func _on_current_option_idx_set() -> void:
	if not is_node_ready():
		return
	
	_name_label.text = tr(selector_text)
	if selector_text != null and not selector_text.is_empty():
		_name_label.text += " "
	
	if current_option_idx == SELECTED_NONE:
		_prev_option_label.text = ""
		_option_label.text = ""
		_next_option_label.text = ""
		return
	
	var option_label_alpha: float = \
			DISABLED_ALPHA if is_option_disabled(current_option_idx) else 1.0
	_option_label.self_modulate.a = option_label_alpha
	
	var options_size = _options.size()
	if options_size == 1:
		_prev_option_label.text = "- "
		_option_label.text = _get_label_for_option(0)
		_next_option_label.text = " -"
		return
	
	_prev_option_label.text = \
			"< " if loop_options or current_option_idx > 0 else ""
	_option_label.text = _get_label_for_option(current_option_idx)
	_next_option_label.text = \
			" >" if loop_options or current_option_idx < options_size - 1 else ""


func _on_selector_text_set() -> void:
	_on_options_set()


func _on_options_set() -> void:
	if is_node_ready():
		_option_disabled_state.resize(_options.size())
		_option_disabled_state.fill(false)
		current_option_idx = SELECTED_NONE if _options.is_empty() else 0


func _on_loop_options_set() -> void:
	_on_current_option_idx_set()


func _on_numbered_list_set() -> void:
	_on_options_set()


func _on_focus_color_set() -> void:
	if is_node_ready():
		_update_bg_color()


func _on_text_font_set() -> void:
	if is_node_ready():
		if text_font:
			for label: Label in _labels:
				label.add_theme_font_override(&"font", text_font)
		else:
			for label: Label in _labels:
				label.remove_theme_font_override(&"font")


func _on_text_color_set() -> void:
	if is_node_ready():
		for label: Label in _labels:
			label.add_theme_color_override(&"font_color", text_color)


func _on_text_size_set() -> void:
	if is_node_ready():
		for label: Label in _labels:
			label.add_theme_font_size_override(&"font_size", text_size)


func _on_focus_entered() -> void:
	_update_bg_color()


func _on_focus_exited() -> void:
	_update_bg_color()
