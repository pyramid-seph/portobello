class_name Day03BossFight
extends Node

signal completed


func prepare() -> void:
	pass


func start() -> void:
	completed.emit()


#	_player.start_timed_invincibility()
#	_player.is_input_enabled = true
