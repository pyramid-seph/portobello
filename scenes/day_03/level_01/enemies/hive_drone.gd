class_name HiveDrone
extends "res://scenes/day_03/_shared/actors/base_day_03_enemy.gd"


@onready var _gun := $Gun as Gun


func _on_set_world(new_world) -> void:
	_gun.world = new_world


func shoot() -> bool:
	return _gun.shoot(Vector2.DOWN)
