extends Wave
class_name Level0Wave0

func _get_enemy() -> PackedScene:
	return preload ("res://scenes/characters/enemy/Drone.tscn")


func _get_enemy_count() -> int:
	return 12
	

func _get_time_between_spawns() -> float:
	return 0.4


func _get_movement_pattern() -> int:
	return Drone.MovementPattern.VERTICAL_DOWN


func _get_initial_position(_movement_pattern: int, screen_size: Vector2) -> Vector2:
	var initial_pos := Vector2()
	initial_pos.x = randi() % int(screen_size.x - 40) + 10
	initial_pos.y = 3
	return initial_pos
