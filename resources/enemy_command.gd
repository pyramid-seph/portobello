@tool
class_name EnemyCommand
extends Resource

@export var _action: BattleAction
@export_range(1.0, 100.0, 1.0, "hide_slider") var _weight: float = 1.0


func get_action() -> BattleAction:
	return _action


func get_weight() -> float:
	return _weight
