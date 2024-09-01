extends ActionArea

@export var _step_one_dialogue_event_01: DialogueEvent
@export var _step_one_dialogue_event_02: DialogueEvent

var _is_executing: bool

@onready var _timer: Timer = $Timer


func _is_executable() -> bool:
	return not _is_executing


func _execute(target: CharacterBody2D) -> void:
	_is_executing = true
	target.set_process_unhandled_input(false)
	DialogueManager.play(_step_one_dialogue_event_01)
	await _step_one_dialogue_event_01.finished
	await TransitionPlayer.play_default()
	# TODO Destroy living room kitchen
	print("Living room destroyed!")
	_timer.start(1.0)
	await _timer.timeout
	await TransitionPlayer.play_default_backwards()
	DialogueManager.play(_step_one_dialogue_event_02)
	await _step_one_dialogue_event_02.finished
	target.set_process_unhandled_input(true)
	_is_executing = false
