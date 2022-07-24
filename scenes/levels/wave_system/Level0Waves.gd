extends Reference
class_name Level0Waves

var waves : Array = [
	_create_wave(5, 0.4, funcref(self, "_00_move_pattern"), funcref(self, "_00_init_pos")),
	_create_wave(5, 0.8, funcref(self, "_01_move_pattern"), funcref(self, "_01_init_pos")),
	_create_wave(5, 0.8, funcref(self, "_02_move_pattern"), funcref(self, "_02_init_pos")),
	_create_wave(5, 1.2, funcref(self, "_03_move_pattern"), funcref(self, "_03_init_pos")),
	_create_wave(5, 0.8, funcref(self, "_04_move_pattern"), funcref(self, "_04_init_pos")),
	_create_wave(00, 15.0, funcref(self, "_05_move_pattern"), funcref(self, "_05_init_pos")),
	_create_wave(5, 1.2, funcref(self, "_06_move_pattern"), funcref(self, "_06_init_pos")),
	_create_wave(50, 1.2, funcref(self, "_07_move_pattern"), funcref(self, "_07_init_pos")),
	_create_wave(5, 1.2, funcref(self, "_08_move_pattern"), funcref(self, "_08_init_pos")),
	_create_wave(5, 1.2, funcref(self, "_09_move_pattern"), funcref(self, "_09_init_pos")),
	_create_wave(5, 1.2, funcref(self, "_10_move_pattern"), funcref(self, "_10_init_pos")),
]


func _create_wave(
	enemy_count: int, 
	time_between_spawns: float, 
	movement_pattern_func: FuncRef, 
	initial_position_func: FuncRef
) -> Wave:
	var wave = Wave.new()
	wave.enemy_count = enemy_count
	wave.time_between_spawns = time_between_spawns
	wave.movement_pattern_func = movement_pattern_func
	wave.initial_position_func = initial_position_func
	return wave


func _get_enemy() -> PackedScene:
	return preload ("res://scenes/characters/enemy/Drone.tscn")


func _00_move_pattern() -> int:
	return Drone.MovementPattern.VERTICAL_DOWN


func _01_move_pattern() -> int:
	if randi() % 2 == 0:
		return Drone.MovementPattern.HORIZONTAL_RIGHT
	else:
		return Drone.MovementPattern.HORIZONTAL_LEFT


func _02_move_pattern() -> int:
	return Drone.MovementPattern.HORIZONTAL_RIGHT


func _03_move_pattern() -> int:
	if randi() % 2 == 0:
		return Drone.MovementPattern.VERTICAL_DOWN
	else:
		return Drone.MovementPattern.VERTICAL_UP


func _04_move_pattern() -> int:
	return Drone.MovementPattern.HORIZONTAL_LEFT


func _05_move_pattern() -> int:
	return Drone.MovementPattern.VERTICAL_DOWN


func _06_move_pattern() -> int:
	return Drone.MovementPattern.SQUARE_UP


func _07_move_pattern() -> int:
	return Drone.MovementPattern.ZIG_ZAG_DOWN


func _08_move_pattern() -> int:
	return Drone.MovementPattern.SQUARE_DOWN


func _09_move_pattern() -> int:
	return Drone.MovementPattern.SQUARE_DOWN


func _10_move_pattern() -> int:
	return Drone.MovementPattern.VERTICAL_UP


func _00_init_pos(_movement_pattern: int, screen_size: Vector2) -> Vector2:
	var initial_pos := Vector2()
	initial_pos.x = randi() % int(screen_size.x - 40) + 10
	initial_pos.y = 3
	return initial_pos


func _01_init_pos(movement_pattern: int, screen_size: Vector2) -> Vector2:
	var initial_pos := Vector2()
	if movement_pattern == Drone.MovementPattern.HORIZONTAL_RIGHT:
		initial_pos.x = 0
	else:
		initial_pos.x = screen_size.x
	initial_pos.y = randi() % int(screen_size.y - 10) + 3
	return initial_pos


func _02_init_pos(_movement_pattern: int, screen_size: Vector2) -> Vector2:
	var initial_pos := Vector2()
	initial_pos.x = 0
	initial_pos.y = randi() % int(screen_size.y - 10) + 3
	return initial_pos


func _03_init_pos(movement_pattern: int, screen_size: Vector2) -> Vector2:
	var initial_pos := Vector2()
	initial_pos.x = randi() % int(screen_size.x - 40) + 10
	if movement_pattern == Drone.MovementPattern.VERTICAL_DOWN:
		initial_pos.y = 0
	else:
		initial_pos.y = screen_size.y - 6
	return initial_pos


func _04_init_pos(_movement_pattern: int, screen_size: Vector2) -> Vector2:
	var initial_pos := Vector2()
	initial_pos.x = screen_size.x
	initial_pos.y = randi() % int(screen_size.y - 10) + 3
	return initial_pos


func _05_init_pos(_movement_pattern: int, _screen_size: Vector2) -> Vector2:
	return Vector2.ZERO


func _06_init_pos(_movement_pattern: int, screen_size: Vector2) -> Vector2:
	var initial_pos := Vector2()
	if randi() % 2 == 0:
		initial_pos.x = 0
	else:
		initial_pos.x = screen_size.x
	initial_pos.y = screen_size.y - 15
	return initial_pos


func _07_init_pos(_movement_pattern: int, screen_size: Vector2) -> Vector2:
	var initial_pos := Vector2()
	match randi() % 4:
		0, 3:
			initial_pos.x = randi() % int(screen_size.x - 20) + 10
			initial_pos.y = 3
		1:
			initial_pos.x = screen_size.x - 16
			initial_pos.y = randi() % 40 + 10
		2: 
			initial_pos.x = 16
			initial_pos.y = randi() % 40 + 10
	return initial_pos


func _08_init_pos(_movement_pattern: int, screen_size: Vector2) -> Vector2:
	var initial_pos := Vector2()
	initial_pos.x = randi() % int(screen_size.x - 20) + 10
	initial_pos.y = 3
	return initial_pos


func _09_init_pos(_movement_pattern: int, screen_size: Vector2) -> Vector2:
	var initial_pos := Vector2()
	if randi() % 2 == 0:
		initial_pos.x = 0
	else:
		initial_pos.x = screen_size.x
	initial_pos.y = randi() % int(screen_size.y - 10) + 3
	return initial_pos


func _10_init_pos(_movement_pattern: int, screen_size: Vector2) -> Vector2:
	var initial_pos := Vector2()
	initial_pos.x = randi() % int(screen_size.x - 40) + 10
	initial_pos.y = screen_size.y - 6
	return initial_pos
