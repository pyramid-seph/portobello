extends LaserBallsCannonState


func enter() -> void:
	cannon._change_balls_color(cannon._charging_color)
	cannon._timer.start(cannon._charging_duration_sec)
	cannon._timer.timeout.connect(_on_charging_timer_timeout, CONNECT_ONE_SHOT)


func exit() -> void:
	if not cannon._timer.is_stopped():
		Utils.safe_disconnect(cannon._timer.timeout, _on_charging_timer_timeout)
		cannon._timer.stop()


func _on_charging_timer_timeout() -> void:
	state_machine.change_state("Detecting")
