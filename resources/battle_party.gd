class_name BattleParty
extends Node


@export var _enemies: Array[BattleEnemyData]
@export_range(1.0, 100.0, 1.0, "hide_slider") var _weight: float


func get_enemies() -> Array[BattleEnemyData]:
	return _enemies


func get_weigth() -> float:
	return _weight
