class_name Hitbox
extends Area2D


signal hit(hitbox: Hitbox, hurtbox: Hurtbox)


func _init() -> void:
	collision_layer = Constants.LAYER_HITBOX
	collision_mask = Constants.LAYER_NONE


func on_successful_hit(hurtbox: Hurtbox) -> void:
	if hurtbox != null:
		hit.emit(self, hurtbox)
