extends LaserBallsCannonState


func enter() -> void:
	cannon._laser.set_deferred("process_mode", PROCESS_MODE_INHERIT)
	cannon._change_balls_color(cannon._charged_color)
	cannon._timer.start(cannon._charged_duration_sec)
	cannon._timer.timeout.connect(_on_charged_timer_timeout, CONNECT_ONE_SHOT)


func exit() -> void:
	cannon._laser.set_deferred("process_mode", PROCESS_MODE_DISABLED)
	if not cannon._timer.is_stopped():
		Utils.safe_disconnect(cannon._timer.timeout, _on_charged_timer_timeout)
		cannon._timer.stop()


func fire() -> void:
	state_machine.change_state()


func _on_charged_timer_timeout() -> void:
	cannon.discharged.emit()
	state_machine.change_state("Discharged")
