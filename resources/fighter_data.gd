class_name FighterData
extends Resource


@export var _char_name: String
@export var _texture: Texture2D
@export var _edible: bool = true
@export var _stats_progression_curve: StatsProgression
@export var _actions: Array[EnemyCommand]

@export_group("Loot", "_loot")
@export_range(0, 99, 1, "hide_slider") var _loot_scraps: int = 1
@export_range(0, 99999, 1, "hide_slider") var _loot_exp: int = 1


func get_char_name() -> String:
	return _char_name


func get_texture() -> Texture2D:
	return _texture


func is_edible() -> bool:
	return _edible


func get_level_by_experience(value: int) -> int:
	return _stats_progression_curve.get_level_by_experience(value)


func get_max_level() -> int:
	return _stats_progression_curve.get_max_level()


func get_min_experience() -> int:
	return _stats_progression_curve.get_min_experience()


func get_max_experience() -> int:
	return _stats_progression_curve.get_max_experience()


func get_base_stats_for_level(level: int) -> Stats:
	return _stats_progression_curve.build_stats_for_level(level)


func get_loot_scraps() -> int:
	return _loot_scraps


func get_loot_exp() -> int:
	return _loot_exp


func get_actions() -> Array[EnemyCommand]:
	return _actions
