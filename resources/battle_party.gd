class_name BattleParty
extends Resource


@export var _front_row: Array[BattleEnemyData]
@export var _back_row: Array[BattleEnemyData]
@export_range(1.0, 100.0, 1.0, "hide_slider") var _weight: float = 1.0


func get_front_row_enemies() -> Array[BattleEnemyData]:
	return _front_row


func get_back_row_enemies() -> Array[BattleEnemyData]:
	return _back_row


func get_weigth() -> float:
	return _weight
