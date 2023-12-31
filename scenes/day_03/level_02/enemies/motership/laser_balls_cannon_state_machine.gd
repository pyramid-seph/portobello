class_name LaserBallsCannonStateMachine
extends StateMachine

func charge() -> void:
	_state.charge()


func fire() -> void:
	_state.fire()


func deactivate() -> void:
	_state.deactivate()
