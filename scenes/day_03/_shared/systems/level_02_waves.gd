extends LevelWaves


const INITIAL_Y = "initial_y"

const Ufo = preload("res://scenes/day_03/level_02/enemies/ufo.tscn")
const Block = preload("res://scenes/day_03/level_02/enemies/block.tscn")


func _create_waves() -> Array[Wave]:
	return [
		Wave.create(10, 0.24, 0.24, _calculate_pattern_00, Ufo),
		Wave.create(10, 0.24, 0.24, _calculate_pattern_01, Ufo),
		Wave.create(10, 0.24, 0.24, _calculate_pattern_02, Ufo),
		Wave.create(10, 0.24, 0.24, _calculate_pattern_03, Ufo),
		Wave.create(60, 0.40, 0.40, _calculate_pattern_04, Ufo),
		Wave.create(10, 1.60, 1.60, _calculate_pattern_05, Ufo),
		Wave.create(20, 0.24, 0.24, _calculate_pattern_06, Ufo),
		Wave.create(20, 1.60, 1.60, _calculate_pattern_07, Ufo),
		Wave.create(20, 1.60, 1.60, _calculate_pattern_08, Block),
		Wave.create(30, 0.80, 0.80, _calculate_pattern_09, Block),
	]


func _calculate_pattern_00(
		_wave_enemy_index: int, 
		player_global_pos: Vector2, 
		_screen_size: Vector2, 
		wave_memo: Dictionary,
) -> SimpleMovement:
	var movement = SimpleMovement.new()
	movement.pattern = SimpleMover.Pattern.HORIZONTAL_RIGHT
	movement.initial_global_position.x = 0
	var pos_y = wave_memo.get(INITIAL_Y, player_global_pos.y)
	wave_memo[INITIAL_Y] = pos_y
	movement.initial_global_position.y = pos_y
	return movement


func _calculate_pattern_01(
		wave_enemy_index: int, 
		player_global_pos: Vector2, 
		screen_size: Vector2, 
		wave_memo: Dictionary,
) -> SimpleMovement:
	return _calculate_pattern_00(
		wave_enemy_index, 
		player_global_pos,
		screen_size,
		wave_memo
	)


func _calculate_pattern_02(
		_wave_enemy_index: int, 
		player_global_pos: Vector2, 
		screen_size: Vector2, 
		wave_memo: Dictionary,
) -> SimpleMovement:
	var movement = SimpleMovement.new()
	movement.pattern = SimpleMover.Pattern.HORIZONTAL_LEFT
	movement.initial_global_position.x = screen_size.x
	var pos_y = wave_memo.get(INITIAL_Y, player_global_pos.y)
	wave_memo[INITIAL_Y] = pos_y
	movement.initial_global_position.y = pos_y
	return movement


func _calculate_pattern_03(
		wave_enemy_index: int, 
		player_global_pos: Vector2, 
		screen_size: Vector2, 
		wave_memo: Dictionary,
) -> SimpleMovement:
	if wave_enemy_index < 5:
		return _calculate_pattern_00(
				wave_enemy_index,
				player_global_pos,
				screen_size,
				wave_memo
		)
	else:
		if wave_enemy_index == 5: wave_memo.erase(INITIAL_Y)
		return _calculate_pattern_02(
				wave_enemy_index, 
				player_global_pos, 
				screen_size, 
				wave_memo
		)


func _calculate_pattern_04(
		_wave_enemy_index: int, 
		player_global_pos: Vector2, 
		_screen_size: Vector2, 
		_wave_memo: Dictionary,
) -> SimpleMovement:
	var movement = SimpleMovement.new()
	movement.pattern = SimpleMover.Pattern.VERTICAL_DOWN
	movement.initial_global_position.x = player_global_pos.x
	movement.initial_global_position.y = 0
	return movement


func _calculate_pattern_05(
	_wave_enemy_index: int, 
	player_global_pos: Vector2, 
	_screen_size: Vector2, 
	_wave_memo: Dictionary,
) -> SimpleMovement:
	var movement = SimpleMovement.new()
	movement.pattern = SimpleMover.Pattern.ZIG_ZAG_DOWN
	movement.initial_global_position.x = player_global_pos.x
	movement.initial_global_position.y = 0
	return movement


func _calculate_pattern_06(
		_wave_enemy_index: int, 
		player_global_pos: Vector2, 
		_screen_size: Vector2, 
		_wave_memo: Dictionary,
) -> SimpleMovement:
	var movement = SimpleMovement.new()
	movement.pattern = SimpleMover.Pattern.SQUARE_DOWN
	movement.initial_global_position.x = player_global_pos.x
	movement.initial_global_position.y = 0
	return movement


func _calculate_pattern_07(
		_wave_enemy_index: int, 
		player_global_pos: Vector2, 
		screen_size: Vector2, 
		_wave_memo: Dictionary,
) -> SimpleMovement:
	var movement = SimpleMovement.new()
	movement.pattern = SimpleMover.Pattern.VERTICAL_UP
	movement.initial_global_position.x = player_global_pos.x
	movement.initial_global_position.y = screen_size.y
	return movement


func _calculate_pattern_08(
		_wave_enemy_index: int, 
		player_global_pos: Vector2, 
		screen_size: Vector2, 
		_wave_memo: Dictionary,
) -> SimpleMovement:
	var movement = SimpleMovement.new()
	if randi() % 2 == 0:
		movement.initial_global_position.x = player_global_pos.x
		if randi() % 2 == 0:
			movement.pattern = SimpleMover.Pattern.VERTICAL_DOWN
			movement.initial_global_position.y = 0
		else:
			movement.pattern = SimpleMover.Pattern.VERTICAL_UP
			movement.initial_global_position.y = screen_size.y - 6
	else:
		if randi() % 2 == 0:
			movement.pattern = SimpleMover.Pattern.HORIZONTAL_RIGHT
			movement.initial_global_position.x = 0
		else:
			movement.pattern = SimpleMover.Pattern.HORIZONTAL_LEFT
			movement.initial_global_position.x = screen_size.x
		movement.initial_global_position.y = player_global_pos.y
	return movement


func _calculate_pattern_09(
		_wave_enemy_index: int, 
		player_global_pos: Vector2, 
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
	movement.initial_global_position.y = player_global_pos.y
	return movement
