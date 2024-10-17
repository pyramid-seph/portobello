class_name SpeakActionArea
extends ActionArea


@export var _dialogue_event: DialogueEvent

var _is_talking: bool


func _is_executable() -> bool:
	return _dialogue_event != null and not _is_talking


func _execute(target: CharacterBody2D) -> void:
	_is_talking = true
	target.set_process_unhandled_input(false)
	DialogueManager.play(_dialogue_event)
	await _dialogue_event.finished
	target.set_process_unhandled_input(true)
	_is_talking = false
