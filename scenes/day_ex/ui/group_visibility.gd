@tool
## Controls the visibility of the referenced Controls
class_name GroupVisibility
extends Control


@export var controls: Array[Control]:
	set(value):
		controls = value
		_update_referenced_controls_visibility()
@export var referenced_controls_visibility: bool = true:
	set(value):
		referenced_controls_visibility = value
		_update_referenced_controls_visibility()


func _ready() -> void:
	_on_visibility_changed()
	visibility_changed.connect(_on_visibility_changed)


func _update_referenced_controls_visibility() -> void:
	if not is_node_ready():
		return
	
	for control: Control in controls:
		if control != null and is_instance_valid(control):
			control.visible = referenced_controls_visibility


func _on_visibility_changed() -> void:
	hide()
