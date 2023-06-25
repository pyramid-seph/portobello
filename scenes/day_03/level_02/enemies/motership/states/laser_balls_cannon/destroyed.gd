extends LaserBallsCannonState


func enter() -> void:
	cannon._set_laser_visibility(false)
	cannon._laser.set_deferred("process_mode", PROCESS_MODE_DISABLED)
#	cannon._change_balls_color(cannon._stand_by_color)
	cannon._change_balls_color(Color.BLACK)
