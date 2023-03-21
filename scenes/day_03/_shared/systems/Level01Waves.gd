extends LevelWaves


const Drone = preload("res://scenes/day_03/level_01/enemies/Drone.tscn")


func _create_waves() -> Array[Wave]:
	return [
		Wave.create(50, 0.4, 0.4, _calculate_pattern_00, Drone),
		Wave.create(50, 0.8, 0.4, _calculate_pattern_01, Drone),
		Wave.create(25, 0.8, 0.4, _calculate_pattern_02, Drone),
		Wave.create(35, 1.2, 0.4, _calculate_pattern_03, Drone),
		Wave.create(40, 0.8, 2.4, _calculate_pattern_04, Drone),
		Wave.create(20, 1.2, 0.4, _calculate_pattern_05, Drone),
		Wave.create(20, 1.2, 0.4, _calculate_pattern_06, Drone),
		Wave.create(30, 1.2, 0.4, _calculate_pattern_07, Drone),
		Wave.create(10, 1.2, 0.4, _calculate_pattern_08, Drone),
		Wave.create(20, 1.2, 0.4, _calculate_pattern_09, Drone),
	]


func _calculate_pattern_00(
		_wave_enemy_index: int,
		_player_global_pos: Vector2, 
		screen_size: Vector2, 
		_wave_memo: Dictionary,
) -> SimpleMovement:
	var movement = SimpleMovement.new()
	movement.pattern = EnemyMovement.Pattern.VERTICAL_DOWN
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
		movement.pattern = EnemyMovement.Pattern.HORIZONTAL_RIGHT
		movement.initial_global_position.x = 0
	else:
		movement.pattern = EnemyMovement.Pattern.HORIZONTAL_LEFT
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
	movement.pattern = EnemyMovement.Pattern.HORIZONTAL_RIGHT
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
		movement.pattern = EnemyMovement.Pattern.VERTICAL_DOWN
		movement.initial_global_position.y = 0
	else:
		movement.pattern = EnemyMovement.Pattern.VERTICAL_UP
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
	movement.pattern = EnemyMovement.Pattern.HORIZONTAL_LEFT
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
	movement.pattern = EnemyMovement.Pattern.SQUARE_UP
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
	movement.pattern = EnemyMovement.Pattern.ZIG_ZAG_DOWN
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
	movement.pattern = EnemyMovement.Pattern.SQUARE_DOWN
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
	movement.pattern = EnemyMovement.Pattern.SQUARE_DOWN
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
	movement.pattern = EnemyMovement.Pattern.VERTICAL_UP
	movement.initial_global_position.x = randi() % int(screen_size.x - 40) + 10
	movement.initial_global_position.y = screen_size.y - 6
	return movement
