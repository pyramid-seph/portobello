@tool
## Controls the visibility of the referenced Controls
class_name GroupVisibility
extends Control

signal referenced_controls_visibility_changed

@export var controls: Array[Control]:
	set(value):
		controls = value
		_update_referenced_controls_visibility()
@export var referenced_controls_visibility: bool = true:
	set(value):
		var old_value: bool = referenced_controls_visibility
		referenced_controls_visibility = value
		_update_referenced_controls_visibility()
		if old_value != value:
			_on_referenced_controls_visibility_changed()


func _ready() -> void:
	_on_self_visibility_changed()
	visibility_changed.connect(_on_self_visibility_changed)


func _update_referenced_controls_visibility() -> void:
	if not is_node_ready():
		return
	
	for control: Control in controls:
		if control != null and is_instance_valid(control):
			control.visible = referenced_controls_visibility
	referenced_controls_visibility_changed.emit()


func _on_referenced_controls_visibility_changed() -> void:
	if is_node_ready():
		referenced_controls_visibility_changed.emit()


func _on_self_visibility_changed() -> void:
	hide()
