@tool
extends PanelContainer

signal positive_btn_pressed
signal negative_btn_pressed

const DEFAULT_SHADOW_COLOR := Color("#000000C8")

@export_multiline var body_text: String = "Body":
	set(value):
		body_text = value
		_on_body_text_set()
@export var negative_btn_text: String = "No":
	set(value):
		negative_btn_text = value
		_on_negative_btn_text_set()
@export var positive_btn_text: String = "Yes":
	set(value):
		positive_btn_text = value
		_on_positive_btn_text_set()
@export var hide_shadow: bool = false:
	set(value):
		hide_shadow = value
		_on_hide_shadow_set()

@onready var _is_ready: bool = true
@onready var _body_label := %BodyLabel as Label
@onready var _negative_btn := %NegativeBtn as Button
@onready var _positive_btn := %PositiveBtn as Button


func _ready() -> void:
	_on_body_text_set()
	_on_negative_btn_text_set()
	_on_positive_btn_text_set()
	_on_hide_shadow_set()
	_on_visibility_changed()


func _hide() -> void:
	visible = false


func _on_positive_btn_text_set() -> void:
	if _is_ready:
		_positive_btn.text = positive_btn_text


func _on_negative_btn_text_set() -> void:
	if _is_ready:
		_negative_btn.text = negative_btn_text
		_negative_btn.visible = not negative_btn_text.is_empty()
		_grab_focus()


func _on_body_text_set() -> void:
	if _is_ready:
		_body_label.text = body_text


func _on_hide_shadow_set() -> void:
	if not _is_ready:
		return
	var curr_theme_style_box := get_theme_stylebox("panel")
	if hide_shadow:
		curr_theme_style_box.bg_color = Color.TRANSPARENT
	else:
		curr_theme_style_box.bg_color = DEFAULT_SHADOW_COLOR


func _grab_focus() -> void:
	if Engine.is_editor_hint():
		return
	var btn = _negative_btn if _negative_btn.visible else _positive_btn
	btn.call_deferred("grab_focus")


func _on_negative_btn_pressed() -> void:
	if Engine.is_editor_hint():
		return
	_hide()
	negative_btn_pressed.emit()


func _on_positive_btn_pressed() -> void:
	if Engine.is_editor_hint():
		return
	_hide()
	positive_btn_pressed.emit()


func _on_visibility_changed() -> void:
	if Engine.is_editor_hint() or not _is_ready:
		return
	if visible:
		_grab_focus()
