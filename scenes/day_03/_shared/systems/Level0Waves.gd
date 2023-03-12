extends LevelWaves
class_name Level0Waves


var _waves: Array[Wave] = []

var DroneScene = preload("res://scenes/day_03/level_01/enemies/Drone.tscn")


func _get_waves() -> Array[Wave]:
	if _waves:
		return _waves
	
	_waves = [
		_create_wave(50, 0.4, 0.4, init_movement_00, DroneScene),
		_create_wave(50, 0.8, 0.4, init_movement_01, DroneScene),
		_create_wave(25, 0.8, 0.4, init_movement_02, DroneScene),
		_create_wave(35, 1.2, 0.4, init_movement_03, DroneScene),
		_create_wave(40, 0.8, 2.4, init_movement_04, DroneScene),
		_create_wave(20, 1.2, 0.4, init_movement_05, DroneScene),
		_create_wave(20, 1.2, 0.4, init_movement_06, DroneScene),
		_create_wave(30, 1.2, 0.4, init_movement_07, DroneScene),
		_create_wave(10, 1.2, 0.4, init_movement_08, DroneScene),
		_create_wave(20, 1.2, 0.4, init_movement_09, DroneScene),
	]
	return _waves


func init_movement_00(screen_size) -> InitialMoveState:
	var initial_movement_state = InitialMoveState.new()
	initial_movement_state.movement_pattern = Drone.MovementPattern.VERTICAL_DOWN
	initial_movement_state.position.x = randi() % int(screen_size.x - 40) + 10
	initial_movement_state.position.y = 3
	return initial_movement_state


func init_movement_01(screen_size) -> InitialMoveState:
	var initial_movement_state = InitialMoveState.new()
	if randi() % 2 == 0:
		initial_movement_state.movement_pattern = Drone.MovementPattern.HORIZONTAL_RIGHT
		initial_movement_state.position.x = 0
	else:
		initial_movement_state.movement_pattern = Drone.MovementPattern.HORIZONTAL_LEFT
		initial_movement_state.position.x =  screen_size.x
	initial_movement_state.position.y = randi() % int(screen_size.y - 10) + 3
	return initial_movement_state


func init_movement_02(screen_size) -> InitialMoveState:
	var initial_movement_state = InitialMoveState.new()
	initial_movement_state.movement_pattern = Drone.MovementPattern.HORIZONTAL_RIGHT
	initial_movement_state.position.x = 0
	initial_movement_state.position.y = randi() % int(screen_size.y - 10) + 3
	return initial_movement_state


func init_movement_03(screen_size) -> InitialMoveState:
	var initial_movement_state = InitialMoveState.new()
	if randi() % 2 == 0:
		initial_movement_state.movement_pattern = Drone.MovementPattern.VERTICAL_DOWN
		initial_movement_state.position.y = 0
	else:
		initial_movement_state.movement_pattern = Drone.MovementPattern.VERTICAL_UP
		initial_movement_state.position.y = screen_size.y - 6
	initial_movement_state.position.x = randi() % int(screen_size.x - 40) + 10	
	return initial_movement_state


func init_movement_04(screen_size) -> InitialMoveState:
	var initial_movement_state = InitialMoveState.new()
	initial_movement_state.movement_pattern = Drone.MovementPattern.HORIZONTAL_LEFT
	initial_movement_state.position.x = screen_size.x
	initial_movement_state.position.y = randi() % int(screen_size.y - 10) + 3
	return initial_movement_state


func init_movement_05(screen_size) -> InitialMoveState:
	var initial_movement_state = InitialMoveState.new()
	initial_movement_state.movement_pattern = Drone.MovementPattern.SQUARE_UP
	if randi() % 2 == 0:
		initial_movement_state.position.x = 0
	else:
		initial_movement_state.position.x = screen_size.x
	initial_movement_state.position.y = screen_size.y - 15
	return initial_movement_state


func init_movement_06(screen_size) -> InitialMoveState:
	var initial_movement_state = InitialMoveState.new()
	initial_movement_state.movement_pattern = Drone.MovementPattern.ZIG_ZAG_DOWN
	match randi() % 4:
		0, 3:
			initial_movement_state.position.x = randi() % int(screen_size.x - 20) + 10
			initial_movement_state.position.y = 3
		1:
			initial_movement_state.position.x = screen_size.x - 16
			initial_movement_state.position.y = randi() % 40 + 10
		2: 
			initial_movement_state.position.x = 16
			initial_movement_state.position.y = randi() % 40 + 10
	return initial_movement_state


func init_movement_07(screen_size) -> InitialMoveState:
	var initial_movement_state = InitialMoveState.new()
	initial_movement_state.movement_pattern = Drone.MovementPattern.SQUARE_DOWN
	initial_movement_state.position.x = randi() % int(screen_size.x - 20) + 10
	initial_movement_state.position.y = 3
	return initial_movement_state


func init_movement_08(screen_size) -> InitialMoveState:
	var initial_movement_state = InitialMoveState.new()
	initial_movement_state.movement_pattern = Drone.MovementPattern.SQUARE_DOWN
	if randi() % 2 == 0:
		initial_movement_state.position.x = 0
	else:
		initial_movement_state.position.x = screen_size.x
	initial_movement_state.position.y = randi() % int(screen_size.y - 10) + 3
	return initial_movement_state


func init_movement_09(screen_size) -> InitialMoveState:
	var initial_movement_state = InitialMoveState.new()
	initial_movement_state.movement_pattern = Drone.MovementPattern.VERTICAL_UP
	initial_movement_state.position.x = randi() % int(screen_size.x - 40) + 10
	initial_movement_state.position.y = screen_size.y - 6
	return initial_movement_state
