class_name HurtBox
extends Area2D

signal hurt(who)


@export var invincible: bool = false :
	get:
		return invincible
	set(mod_value):
		invincible = mod_value
		collision_shape.set_deferred("disabled", invincible)

@onready var collision_shape := $CollisionShape2D


func _on_HurtBox_area_entered(area: Area2D) -> void:
	emit_signal("hurt", area)
