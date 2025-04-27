extends Node


func _exit_tree() -> void:
	if not Engine.is_editor_hint():
		stop()


func play() -> void:
	pass # NOOP


func stop() -> void:
	pass # NOOP
