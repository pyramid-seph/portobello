class_name LaserBallsCannonState
extends State


var cannon: LaserBallsCannon


func _ready() -> void:
	await owner.ready
	cannon = owner as LaserBallsCannon
	assert(cannon != null)


func charge() -> void:
	pass


func fire() -> void:
	pass


func deactivate() -> void:
	state_machine.change_state("StandBy")
