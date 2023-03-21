class_name Wave
extends RefCounted

var enemy_count: int = 0
var time_between_spawns: float = 0.0
var time_between_waves: float = 0.0
var calculate_pattern: Callable
var Enemy: PackedScene

static func create(
		enemy_count_val: int, 
		time_between_spawns_val: float,
		time_between_waves_val: float,
		calculate_pattern_val: Callable,
		enemy_scene_val: PackedScene
) -> Wave:
	var wave = Wave.new()
	wave.enemy_count = enemy_count_val
	wave.time_between_spawns = time_between_spawns_val
	wave.time_between_waves = time_between_waves_val
	wave.calculate_pattern = calculate_pattern_val
	wave.Enemy = enemy_scene_val
	return wave
