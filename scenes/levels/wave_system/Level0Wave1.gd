extends Wave
class_name Level0Wave1


func _get_movement_pattern():
	if randi() % 2 == 0:
		return Drone.MovementPattern.HORIZONTAL_RIGHT
	else:
		return Drone.MovementPattern.HORIZONTAL_LEFT


func _get_initial_position(movement_pattern, screen_size) -> Vector2:
	var initial_pos := Vector2()
	if movement_pattern == Drone.MovementPattern.HORIZONTAL_RIGHT:
		initial_pos.x = 0
	else:
		initial_pos.x = screen_size.x
		initial_pos.y = randi() % int(screen_size.y - 10) + 3
	return initial_pos
