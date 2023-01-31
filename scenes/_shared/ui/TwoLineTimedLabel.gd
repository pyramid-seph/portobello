@tool
extends VBoxContainer


@export var text_1: String = "Hi":
	set(value):
		text_1 = value
		if Engine.is_editor_hint() and label_1:
			label_1.text = text_1
	get:
		return text_1
@export var text_2: String = "World":
	set(value):
		text_2 = value
		if Engine.is_editor_hint() and label_2:
			label_2.text = text_2
	get:
		return text_2
@export_color_no_alpha var label_font_color = Color.MAGENTA:
	set(value):
		label_font_color = value
		if Engine.is_editor_hint() and label_1:
			_change_label_1_color(label_font_color)
			if not show_color_out and label_2:
				_change_label_2_color(label_font_color)
	get:
		return label_font_color
@export_color_no_alpha var label_font_color_out = Color.MAGENTA:
	set(value):
		label_font_color_out = value
		if Engine.is_editor_hint() and label_2 and show_color_out:
			_change_label_2_color(label_font_color_out)
@export var show_color_out: bool = false:
	set(value):
		show_color_out = value
		if Engine.is_editor_hint() and label_2:
			if show_color_out:
				_change_label_2_color(label_font_color_out)
			else:
				_change_label_2_color(label_font_color)
	get:
		return show_color_out
@export var duration_sec: float = 4.32
@export var label_2_visibility_delay_sec: float = 1.6
@export var label_2_fade_out_delay_sec: float = 1.36

var _tween: Tween
var _make_invisible_delay_sec = 0

@onready var label_1 := $Label as Label
@onready var label_2 := $Label2 as Label


func _ready() -> void:
	_make_invisible_delay_sec = label_2_visibility_delay_sec - label_2_fade_out_delay_sec
	label_1.text = text_1
	label_2.text = text_2
	_change_label_1_color(label_font_color)
	if Engine.is_editor_hint() and show_color_out:
		_change_label_2_color(label_font_color_out)
	else:
		_change_label_2_color(label_font_color)


func start() -> void:
	if _tween:
		_tween.kill()
	_tween = create_tween()
	_tween.tween_callback(func(): 
		visible = true
		label_2.visible = false
		_change_label_2_color(label_font_color)
	)
	_tween.tween_callback(func(): 
		label_2.visible = true
	).set_delay(duration_sec - label_2_visibility_delay_sec)
	_tween.tween_callback(
		_change_label_2_color.bind(label_font_color_out)
	).set_delay(label_2_fade_out_delay_sec)
	_tween.tween_callback(func(): 
		visible = false
		_tween = null
	).set_delay(_make_invisible_delay_sec)


func _change_label_1_color(color: Color) -> void:
	label_1.remove_theme_color_override("font_color")
	label_1.add_theme_color_override("font_color", color)


func _change_label_2_color(color: Color) -> void:
	label_2.remove_theme_color_override("font_color")
	label_2.add_theme_color_override("font_color", color)
