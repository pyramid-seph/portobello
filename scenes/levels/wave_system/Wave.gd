extends Reference
class_name Wave


var enemies_count: int = 10
var time_between_spawns: float = 0.4


func _get_movement_pattern():
	return Drone.MovementPattern.VERTICAL_DOWN


func _get_initial_position(movement_pattern, screen_size: Vector2) -> Vector2:
	return Vector2.ZERO
