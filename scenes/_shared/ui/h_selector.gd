@tool
class_name HSelector
extends PanelContainer

signal selected(value)
signal current_option_index_changed(value: int)

const SELECTED_NONE: int = -1

@export var selector_text: String:
	set(value):
		selector_text = value
		_on_selector_text_set()
@export var options: Array:
	set(value):
		options = value
		_on_options_set()
@export var focus_color: Color = Color.MAGENTA:
	set(value):
		focus_color = value
		_on_focus_color_set()
@export var loop_options: bool = true:
	set(value):
		loop_options = value
		_on_loop_options_set()

var current_option_idx: int = SELECTED_NONE:
	set(value):
		var old_value = current_option_idx
		current_option_idx = clampi(value, SELECTED_NONE, options.size() - 1)
		_on_current_option_idx_set()
		if not Engine.is_editor_hint() and old_value != current_option_idx:
			current_option_index_changed.emit(current_option_idx)

@onready var _is_ready: bool = true
@onready var _label := $Label as Label


func _ready() -> void:
	_on_options_set()
	_on_current_option_idx_set()
	_on_focus_color_set()
	_update_bg_color()


func _gui_input(event: InputEvent) -> void:
	if Engine.is_editor_hint():
		return
	
	if event.is_action_pressed("ui_accept") and current_option_idx > SELECTED_NONE:
		selected.emit(_get_value_for_option(current_option_idx))
		accept_event()
	if event.is_action_pressed("ui_left"):
		_previous_option()
		accept_event()
	if event.is_action_pressed("ui_right"):
		_next_option()
		accept_event()


func _previous_option() -> void:
	if options.is_empty():
		current_option_idx = SELECTED_NONE
		return
	
	if loop_options:
		current_option_idx = wrapi(current_option_idx - 1, 0, options.size())
	else:
		current_option_idx = maxi(current_option_idx - 1, 0)


func _next_option() -> void:
	if options.is_empty():
		current_option_idx = SELECTED_NONE
		return
	
	if loop_options:
		current_option_idx = wrapi(current_option_idx + 1, 0, options.size())
	else:
		current_option_idx = mini(options.size() - 1, current_option_idx + 1)


func _update_bg_color() -> void:
	var curr_theme_style_box := get_theme_stylebox("panel")
	if has_focus():
		curr_theme_style_box.bg_color = focus_color
	else:
		curr_theme_style_box.bg_color = Color.TRANSPARENT


func _get_label_for_option(idx: int) -> String:
	var option = options[idx]
	if typeof(option) == TYPE_DICTIONARY:
		return option.label
	else:
		return option


func _get_value_for_option(idx: int):
	var option = options[idx]
	if typeof(option) == TYPE_DICTIONARY:
		return option.value
	else:
		return idx


func _on_current_option_idx_set() -> void:
	if not _is_ready:
		return
	
	_label.text = selector_text
	if selector_text != null and not selector_text.is_empty():
		_label.text += " "
	
	if current_option_idx == SELECTED_NONE:
		return
	
	if options.size() == 1:
		_label.text += "- %s -" % _get_label_for_option(0)
		return
	
	if loop_options or current_option_idx > 0:
		_label.text += "< "
	_label.text += _get_label_for_option(current_option_idx)
	if loop_options or current_option_idx < options.size() - 1:
		_label.text += " >"


func _on_selector_text_set() -> void:
	_on_options_set()


func _on_options_set() -> void:
	if _is_ready:
		current_option_idx = SELECTED_NONE if options.is_empty() else 0


func _on_loop_options_set() -> void:
	_on_current_option_idx_set()


func _on_focus_color_set() -> void:
	if _is_ready:
		_update_bg_color()


func _on_focus_entered() -> void:
	_update_bg_color()


func _on_focus_exited() -> void:
	_update_bg_color()
