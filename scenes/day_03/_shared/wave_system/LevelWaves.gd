extends RefCounted
class_name LevelWaves


func _get_enemy_scene() -> PackedScene:
	return null


func _get_waves() -> Array[Wave]:
	return [];


func _create_wave(
	enemy_count: int, 
	time_between_spawns: float,
	time_between_waves: float,
	init_move_state_func_name: Callable
) -> Wave:
	var wave = Wave.new()
	wave.enemy_count = enemy_count
	wave.time_between_spawns = time_between_spawns
	wave.time_between_waves = time_between_waves
	wave.get_initial_move_state_func = init_move_state_func_name
	return wave
