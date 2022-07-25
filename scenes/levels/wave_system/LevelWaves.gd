extends Reference
class_name LevelWaves


func _get_enemy_scene() -> PackedScene:
	return null


func _get_waves() -> Array:
	return [];


func _create_wave(
	enemy_count: int, 
	time_between_spawns: float, 
	init_move_state_func_name: String
) -> Wave:
	var wave = Wave.new()
	wave.enemy_count = enemy_count
	wave.time_between_spawns = time_between_spawns
	wave.get_initial_move_state_func = funcref(self, init_move_state_func_name)
	return wave
