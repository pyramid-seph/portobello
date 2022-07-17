extends Reference
class_name Level0Waves

var waves := [
	{
		"enemy_count": 12,
		"time_between_spawns": 0.4,
		"movement_pattern": funcref(self, "_wave_0_get_movement_pattern"),
		"initial_position": funcref(self, "_wave_0_get_initial_position")
	},
	{
		"enemy_count": 5,
		"time_between_spawns": 0.8,
		"movement_pattern": funcref(self, "_wave_1_get_movement_pattern"),
		"initial_position": funcref(self, "_wave_1_get_initial_position")
	}
]

func _get_enemy() -> PackedScene:
	return preload ("res://scenes/characters/enemy/Drone.tscn")


func _wave_0_get_movement_pattern() -> int:
	return Drone.MovementPattern.VERTICAL_DOWN


func _wave_1_get_movement_pattern() -> int:
	if randi() % 2 == 0:
		return Drone.MovementPattern.HORIZONTAL_RIGHT
	else:
		return Drone.MovementPattern.HORIZONTAL_LEFT


func _wave_0_get_initial_position(movement_pattern: int, screen_size: Vector2) -> Vector2:
	var initial_pos := Vector2()
	initial_pos.x = randi() % int(screen_size.x - 40) + 10
	initial_pos.y = 3
	return initial_pos


func _wave_1_get_initial_position(movement_pattern: int, screen_size: Vector2) -> Vector2:
	var initial_pos := Vector2()
	if movement_pattern == Drone.MovementPattern.HORIZONTAL_RIGHT:
		initial_pos.x = 0
	else:
		initial_pos.x = screen_size.x
	initial_pos.y = randi() % int(screen_size.y - 10) + 3
	return initial_pos
