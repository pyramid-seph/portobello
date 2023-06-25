class_name Wave
extends RefCounted

var enemy_count: int = 0
var time_between_spawns: float = 0.0
var time_between_waves: float = 0.0
var calculate_pattern: Callable
var Enemy: PackedScene

func _init(
		enemy_count_val: int, 
		time_between_spawns_val: float,
		time_between_waves_val: float,
		calculate_pattern_val: Callable,
		enemy_scene_val: PackedScene
) -> void:
	enemy_count = enemy_count_val
	time_between_spawns = time_between_spawns_val
	time_between_waves = time_between_waves_val
	calculate_pattern = calculate_pattern_val
	Enemy = enemy_scene_val
