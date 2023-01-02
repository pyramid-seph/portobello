class_name HurtBox
extends Area2D

signal hurt(who)


@export var invincible: bool := false : set = set_invincible

@onready var collision_shape := $CollisionShape2D


func set_invincible(value: bool) -> void:
	invincible = value
	collision_shape.set_deferred("disabled", invincible)


func _on_HurtBox_area_entered(area: Area2D) -> void:
	emit_signal("hurt", area)
