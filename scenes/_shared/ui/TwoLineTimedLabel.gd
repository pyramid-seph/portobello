@tool
extends Control


@export var text_1: String = "Hi":
	set(value):
		text_1 = value
		if Engine.is_editor_hint():
			_set_label_text_1()
	get:
		return text_1
@export var text_2: String = "World!":
	set(value):
		text_2 = value
		if Engine.is_editor_hint():
			_set_label_text_2()
	get:
		return text_2
@export_color_no_alpha var label_font_color = Color.MAGENTA:
	set(value):
		label_font_color = value
		if Engine.is_editor_hint():
			_change_label_1_color(label_font_color)
	get:
		return label_font_color
@export_color_no_alpha var label_font_color_out = Color("ff7fff")
@export var duration_sec: float = 4.32
@export var label_2_visibility_delay_sec: float = 1.6
@export var label_2_fade_out_delay_sec: float = 1.36
@export var preview_labels: bool = true:
	set(value):
		preview_labels = value
		if Engine.is_editor_hint():
			if label_1: label_1.visible = preview_labels
			if label_2: label_2.visible = preview_labels
	get:
		return preview_labels

var _tween: Tween

@onready var label_1 := $Labels/Label as Label
@onready var label_2 := $Labels/Label2 as Label


func _ready() -> void:
	_set_label_text_1()
	_set_label_text_2()
	_change_label_1_color(label_font_color)
	_change_label_2_color(label_font_color)
	
	if Engine.is_editor_hint():
		label_1.visible = preview_labels
		label_2.visible = preview_labels
	else:
		label_1.visible = false
		label_2.visible = false


func start() -> void:
	label_1.visible = true
	label_2.visible = false
	_set_label_text_1()
	_set_label_text_2()
	_change_label_1_color(label_font_color)
	_change_label_2_color(label_font_color)
	var finish_delay_sec = label_2_visibility_delay_sec - label_2_fade_out_delay_sec
	
	if _tween: _tween.kill()
	_tween = create_tween()
	_tween.tween_callback(func(): 
		label_2.visible = true
	).set_delay(duration_sec - label_2_visibility_delay_sec)
	_tween.tween_callback(
		_change_label_2_color.bind(label_font_color_out)
	).set_delay(label_2_fade_out_delay_sec)
	_tween.tween_callback(func(): 
		label_1.visible = false
		label_2.visible = false
		_tween = null
	).set_delay(finish_delay_sec)


func _set_label_text_1() -> void:
	if not label_1: return
	label_1.text = text_1


func _set_label_text_2() -> void:
	if not label_2: return
	label_2.text = text_2


func _change_label_1_color(color: Color) -> void:
	if not label_1: return
	label_1.remove_theme_color_override("font_color")
	label_1.add_theme_color_override("font_color", color)


func _change_label_2_color(color: Color) -> void:
	if not label_2: return
	label_2.remove_theme_color_override("font_color")
	label_2.add_theme_color_override("font_color", color)
