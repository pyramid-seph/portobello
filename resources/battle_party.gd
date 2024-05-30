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


func count_enemy_ocurrences() -> Dictionary:
	var count: Dictionary = {}
	_accumulate_enemy_counts_from_row(_front_row, count)
	_accumulate_enemy_counts_from_row(_back_row, count)
	return count
	
	
func _accumulate_enemy_counts_from_row(row: Array[BattleEnemyData], 
		count: Dictionary) -> void:
	for enemy_data: BattleEnemyData in row:
		var enemy_name: String = enemy_data.get_enemy_name()
		if count.has(enemy_name):
			count[enemy_name] += 1
		else:
			count[enemy_name] = 1
