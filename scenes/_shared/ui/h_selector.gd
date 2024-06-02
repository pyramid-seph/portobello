@tool
class_name HSelector
extends PanelContainer

signal selected(value)
signal current_option_index_changed(index: int)

const SELECTED_NONE: int = -1

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

@onready var _label := $Label as Label


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
		if release_focus_on_selection:
			release_focus()
		selected.emit(_get_value_for_option(current_option_idx))
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
	var curr_theme_style_box := get_theme_stylebox("panel")
	if has_focus():
		curr_theme_style_box.bg_color = focus_color
	else:
		curr_theme_style_box.bg_color = Color.TRANSPARENT


func _get_label_for_option(idx: int) -> String:
	var option = _options[idx]
	if typeof(option) == TYPE_DICTIONARY:
		return tr(option.label)
	else:
		return tr(option)


func _get_value_for_option(idx: int):
	var option = _options[idx]
	if typeof(option) == TYPE_DICTIONARY:
		return option.value
	else:
		return idx


func _on_current_option_idx_set() -> void:
	if not is_node_ready():
		return
	
	_label.text = tr(selector_text)
	if selector_text != null and not selector_text.is_empty():
		_label.text += " "
	
	if current_option_idx == SELECTED_NONE:
		return
	
	if _options.size() == 1:
		_label.text += "- %s -" % _get_label_for_option(0)
		return
	
	if loop_options or current_option_idx > 0:
		_label.text += "< "
	_label.text += _get_label_for_option(current_option_idx)
	if loop_options or current_option_idx < _options.size() - 1:
		_label.text += " >"


func _on_selector_text_set() -> void:
	_on_options_set()


func _on_options_set() -> void:
	if is_node_ready():
		current_option_idx = SELECTED_NONE if _options.is_empty() else 0


func _on_loop_options_set() -> void:
	_on_current_option_idx_set()


func _on_focus_color_set() -> void:
	if is_node_ready():
		_update_bg_color()


func _on_text_font_set() -> void:
	if is_node_ready():
		if text_font:
			_label.add_theme_font_override("font", text_font)
		else:
			_label.remove_theme_font_override("font")


func _on_text_color_set() -> void:
	if is_node_ready():
		_label.add_theme_color_override("font_color", text_color)


func _on_text_size_set() -> void:
	if is_node_ready():
		_label.add_theme_font_size_override("font_size", text_size)


func _on_focus_entered() -> void:
	_update_bg_color()


func _on_focus_exited() -> void:
	_update_bg_color()
