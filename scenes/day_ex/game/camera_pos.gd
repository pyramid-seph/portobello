@tool
class_name CameraPos
extends Node2D


@export var _preview_color: Color:
	set(value):
		_preview_color = value
		queue_redraw()

var _viewport_size: Vector2


func _ready() -> void:
	if Engine.is_editor_hint():
		ProjectSettings.settings_changed.connect(_on_settings_changed)
		_on_settings_changed()


func _draw() -> void:
	if Engine.is_editor_hint():
		var preview_rect := Rect2(Vector2.ZERO, _viewport_size)
		draw_rect(preview_rect, _preview_color, false, 1.0)


func _on_settings_changed() -> void:
	var old_viewport_size = _viewport_size
	var viewport_width: int = \
			ProjectSettings.get_setting("display/window/size/viewport_width")
	var viewport_height: int = \
			ProjectSettings.get_setting("display/window/size/viewport_height")
	_viewport_size = Vector2(viewport_width, viewport_height)
	if _viewport_size != old_viewport_size:
		queue_redraw()
