extends Wave
class_name Level0Wave0


func _get_movement_pattern():
	return Drone.MovementPattern.VERTICAL_DOWN


func _get_initial_position(_movement_pattern, screen_size) -> Vector2:
	var initial_pos := Vector2()
	initial_pos.x = randi() % int(screen_size.x - 40) + 10
	initial_pos.y = 3
	return initial_pos
