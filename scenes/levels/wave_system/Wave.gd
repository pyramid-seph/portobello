extends Reference
class_name Wave


func _get_max_concurrent_enemies() -> int:
	return 10


func _get_enemy() -> PackedScene:
	return null


func _get_enemy_count() -> int:
	return 0


func _get_time_between_spawns() -> float:
	return 0.0


func _get_movement_pattern() -> int:
	return Drone.MovementPattern.VERTICAL_DOWN


func _get_initial_position(_movement_pattern: int, _screen_size: Vector2) -> Vector2:
	return Vector2.ZERO
