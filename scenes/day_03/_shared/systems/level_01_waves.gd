extends LevelWaves


const DroneScene = preload("res://scenes/day_03/level_01/enemies/drone.tscn")


func _create_waves() -> Array[Wave]:
	return [
		Wave.new(50, 0.4, 0.4, _calculate_pattern_00, DroneScene),
		Wave.new(50, 0.8, 0.4, _calculate_pattern_01, DroneScene),
		Wave.new(25, 0.8, 0.4, _calculate_pattern_02, DroneScene),
		Wave.new(35, 1.2, 0.4, _calculate_pattern_03, DroneScene),
		Wave.new(40, 0.8, 2.4, _calculate_pattern_04, DroneScene),
		Wave.new(20, 1.2, 0.4, _calculate_pattern_05, DroneScene),
		Wave.new(20, 1.2, 0.4, _calculate_pattern_06, DroneScene),
		Wave.new(30, 1.2, 0.4, _calculate_pattern_07, DroneScene),
		Wave.new(10, 1.2, 0.4, _calculate_pattern_08, DroneScene),
		Wave.new(20, 1.2, 0.4, _calculate_pattern_09, DroneScene),
	]


func _calculate_pattern_00(
		_wave_enemy_index: int,
		_player_global_pos: Vector2, 
		screen_size: Vector2, 
		_wave_memo: Dictionary,
) -> SimpleMovement:
	var movement = SimpleMovement.new()
	movement.pattern = SimpleMover.Pattern.VERTICAL_DOWN
	movement.initial_global_position.x = randi() % int(screen_size.x - 40) + 10
	movement.initial_global_position.y = 3
	return movement


func _calculate_pattern_01(
		_wave_enemy_index: int,
		_player_global_pos: Vector2, 
		screen_size: Vector2, 
		_wave_memo: Dictionary,
) -> SimpleMovement:
	var movement = SimpleMovement.new()
	if randi() % 2 == 0:
		movement.pattern = SimpleMover.Pattern.HORIZONTAL_RIGHT
		movement.initial_global_position.x = 0
	else:
		movement.pattern = SimpleMover.Pattern.HORIZONTAL_LEFT
		movement.initial_global_position.x = screen_size.x
	movement.initial_global_position.y = randi() % int(screen_size.y - 10) + 3
	return movement


func _calculate_pattern_02(
		_wave_enemy_index: int,
		_player_global_pos: Vector2, 
		screen_size: Vector2, 
		_wave_memo: Dictionary,
) -> SimpleMovement:
	var movement = SimpleMovement.new()
	movement.pattern = SimpleMover.Pattern.HORIZONTAL_RIGHT
	movement.initial_global_position.x = 0
	movement.initial_global_position.y = randi() % int(screen_size.y - 10) + 3
	return movement


func _calculate_pattern_03(
		_wave_enemy_index: int,
		_player_global_pos: Vector2, 
		screen_size: Vector2, 
		_wave_memo: Dictionary,
) -> SimpleMovement:
	var movement = SimpleMovement.new()
	if randi() % 2 == 0:
		movement.pattern = SimpleMover.Pattern.VERTICAL_DOWN
		movement.initial_global_position.y = 0
	else:
		movement.pattern = SimpleMover.Pattern.VERTICAL_UP
		movement.initial_global_position.y = screen_size.y - 6
	movement.initial_global_position.x = randi() % int(screen_size.x - 40) + 10	
	return movement


func _calculate_pattern_04(
		_wave_enemy_index: int,
		_player_global_pos: Vector2, 
		screen_size: Vector2, 
		_wave_memo: Dictionary,
) -> SimpleMovement:
	var movement = SimpleMovement.new()
	movement.pattern = SimpleMover.Pattern.HORIZONTAL_LEFT
	movement.initial_global_position.x = screen_size.x
	movement.initial_global_position.y = randi() % int(screen_size.y - 10) + 3
	return movement


func _calculate_pattern_05(
		_wave_enemy_index: int,
		_player_global_pos: Vector2, 
		screen_size: Vector2, 
		_wave_memo: Dictionary,
) -> SimpleMovement:
	var movement = SimpleMovement.new()
	movement.pattern = SimpleMover.Pattern.SQUARE_UP
	if randi() % 2 == 0:
		movement.initial_global_position.x = 0
	else:
		movement.initial_global_position.x = screen_size.x
	movement.initial_global_position.y = screen_size.y - 15
	return movement


func _calculate_pattern_06(
		_wave_enemy_index: int,
		_player_global_pos: Vector2, 
		screen_size: Vector2, 
		_wave_memo: Dictionary,
) -> SimpleMovement:
	var movement = SimpleMovement.new()
	movement.pattern = SimpleMover.Pattern.ZIG_ZAG_DOWN
	match randi() % 4:
		0, 3:
			movement.initial_global_position.x = randi() % int(screen_size.x - 20) + 10
			movement.initial_global_position.y = 3
		1:
			movement.initial_global_position.x = screen_size.x - 16
			movement.initial_global_position.y = randi() % 40 + 10
		2: 
			movement.initial_global_position.x = 16
			movement.initial_global_position.y = randi() % 40 + 10
	return movement


func _calculate_pattern_07(
		_wave_enemy_index: int,
		_player_global_pos: Vector2, 
		screen_size: Vector2, 
		_wave_memo: Dictionary,
) -> SimpleMovement:
	var movement = SimpleMovement.new()
	movement.pattern = SimpleMover.Pattern.SQUARE_DOWN
	movement.initial_global_position.x = randi() % int(screen_size.x - 20) + 10
	movement.initial_global_position.y = 3
	return movement


func _calculate_pattern_08(
		_wave_enemy_index: int,
		_player_global_pos: Vector2, 
		screen_size: Vector2, 
		_wave_memo: Dictionary,
) -> SimpleMovement:
	var movement = SimpleMovement.new()
	movement.pattern = SimpleMover.Pattern.SQUARE_DOWN
	if randi() % 2 == 0:
		movement.initial_global_position.x = 0
	else:
		movement.initial_global_position.x = screen_size.x
	movement.initial_global_position.y = randi() % int(screen_size.y - 10) + 3
	return movement


func _calculate_pattern_09(
		_wave_enemy_index: int,
		_player_global_pos: Vector2, 
		screen_size: Vector2, 
		_wave_memo: Dictionary,
) -> SimpleMovement:
	var movement = SimpleMovement.new()
	movement.pattern = SimpleMover.Pattern.VERTICAL_UP
	movement.initial_global_position.x = randi() % int(screen_size.x - 40) + 10
	movement.initial_global_position.y = screen_size.y - 6
	return movement
