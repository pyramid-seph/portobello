extends LaserBallsCannonState


func enter() -> void:
	cannon._change_balls_color(cannon._stand_by_color)


func charge() -> void:
	state_machine.change_state("Charging")
