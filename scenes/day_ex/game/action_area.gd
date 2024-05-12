class_name ActionArea
extends Area2D


func _ready() -> void:
	collision_layer = Constants.LAYER_ACTION_AREA
	collision_mask = Constants.LAYER_NONE


@warning_ignore("unused_parameter")
# Override.
func execute(target: CharacterBody2D) -> void:
	pass
