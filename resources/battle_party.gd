class_name BattleParty
extends Resource


@export var _front_row: Array[FighterData]
@export var _back_row: Array[FighterData]
@export_range(1.0, 100.0, 1.0, "hide_slider") var _weight: float = 1.0


func get_front_row_members() -> Array[FighterData]:
	return _front_row


func get_back_row_members() -> Array[FighterData]:
	return _back_row


func get_weigth() -> float:
	return _weight


func count_member_ocurrences() -> Dictionary[String, int]:
	var count: Dictionary[String, int] = {}
	_accumulate_member_ocurrences_from_row(_front_row, count)
	_accumulate_member_ocurrences_from_row(_back_row, count)
	return count
	
	
func _accumulate_member_ocurrences_from_row(row: Array[FighterData], 
		count: Dictionary[String, int]) -> void:
	for fighter_data: FighterData in row:
		var fighter_name: String = fighter_data.get_char_name()
		if count.has(fighter_name):
			count[fighter_name] += 1
		else:
			count[fighter_name] = 1
