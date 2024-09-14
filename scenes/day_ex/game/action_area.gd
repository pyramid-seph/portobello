class_name ActionArea
extends Area2D


func _ready() -> void:
	collision_layer = Constants.LAYER_ACTION_AREA
	collision_mask = Constants.LAYER_NONE


func is_executable() -> bool:
	return _is_executable()


func execute(target: CharacterBody2D) -> void:
	if _is_executable():
		_execute(target)


# Virtual method.
func _is_executable() -> bool:
	return true


# Virtual method.
@warning_ignore("unused_parameter")
func _execute(target: CharacterBody2D) -> void:
	pass
