extends LaserBallsCannonState


var _tween: Tween


func enter() -> void:
	var loops = ceili(cannon._laser_duration_sec / (Utils.FRAME_TIME * 2.0))
	_cancel_tween()
	_tween = create_tween()
	_tween.tween_callback(func():
		cannon._set_laser_visibility(true)
		cannon._change_balls_color(cannon._charged_color)
	)
	_tween.set_loops(loops)
	_tween.tween_callback(cannon._inner_color.set_modulate.bind(cannon._laser_int_color_1))
	_tween.tween_callback(cannon._outer_color.set_modulate.bind(cannon._laser_ext_color_1))
	_tween.tween_interval(Utils.FRAME_TIME)
	_tween.tween_callback(cannon._inner_color.set_modulate.bind(cannon._laser_int_color_2))
	_tween.tween_callback(cannon._outer_color.set_modulate.bind(cannon._laser_ext_color_2))
	_tween.tween_interval(Utils.FRAME_TIME)
	_tween.finished.connect(_on_firing_finished, CONNECT_ONE_SHOT)


func exit() -> void:
	if _tween.is_running():
		Utils.safe_disconnect(_tween.finished, _on_firing_finished)
	_cancel_tween()
	cannon._set_laser_visibility(false)


func _cancel_tween() -> void:
	if _tween:
		_tween.kill()


func _on_firing_finished() -> void:
	state_machine.change_state("Discharged") 
