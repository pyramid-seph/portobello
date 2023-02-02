@tool
extends Control


const TIME_BETWEEN_FADES: float = Utils.FRAME_TIME

@export var text_1: String = "Hi":
	set(value):
		text_1 = value
		if Engine.is_editor_hint():
			_set_label_1_text()
	get:
		return text_1
@export var text_2: String = "World!":
	set(value):
		text_2 = value
		if Engine.is_editor_hint():
			_set_label_2_text()
	get:
		return text_2
@export_color_no_alpha var font_color_normal: Color = Color.MAGENTA:
	set(value):
		font_color_normal = value
		if Engine.is_editor_hint():
			_change_label_1_color(font_color_normal)
			_change_label_2_color(font_color_normal)
	get:
		return font_color_normal
@export_color_no_alpha var font_color_fade_1: Color = Color.MAGENTA
@export_color_no_alpha var font_color_fade_3: Color = Color.MAGENTA
@export var duration_sec: float = 4.32
@export var label_2_visible_delay_sec: float = 1.60
@export var preview_labels: bool = true:
	set(value):
		preview_labels = value
		if Engine.is_editor_hint():
			_change_labels_visible(preview_labels)
	get:
		return preview_labels

var _tween: Tween

@onready var _labels = $Labels
@onready var _label_1 := $Labels/Label as Label
@onready var _label_2 := $Labels/Label2 as Label


func _ready() -> void:
	_set_label_1_text()
	_set_label_2_text()
	_change_label_1_color(font_color_normal)
	_change_label_2_color(font_color_normal)
	
	if Engine.is_editor_hint():
		_change_labels_visible(preview_labels)
	else:
		_change_labels_visible(false)


func start() -> void:
	_labels.visible = true
	_set_label_1_text()
	_set_label_2_text()
	_change_label_1_color(font_color_normal)
	_change_label_2_color(Color.TRANSPARENT)
	
	if _tween: _tween.kill()
	_tween = create_tween()
	_tween.tween_callback(
		_change_label_2_color.bind(font_color_normal)
	).set_delay(label_2_visible_delay_sec)
	_tween.tween_interval(duration_sec - label_2_visible_delay_sec - 3 * TIME_BETWEEN_FADES)
	_tween.tween_method(
		_change_label_2_color,
		font_color_fade_1,
		font_color_fade_3,
		3 * TIME_BETWEEN_FADES
	).set_trans(Tween.TRANS_LINEAR)
	_tween.tween_callback(func(): 
		_change_labels_visible(false)
		_tween = null
	)


func _set_label_1_text() -> void:
	if _label_1: _label_1.text = text_1


func _set_label_2_text() -> void:
	if _label_2: _label_2.text = text_2


func _change_labels_visible(value: bool) -> void:
	if _labels: _labels.visible = value


func _change_label_color(label: Label, color: Color) -> void:
	if not label: return
	label.remove_theme_color_override("font_color")
	label.add_theme_color_override("font_color", color)


func _change_label_1_color(color: Color) -> void:
	_change_label_color(_label_1, color)


func _change_label_2_color(color: Color) -> void:
	_change_label_color(_label_2, color)
