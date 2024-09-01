extends ActionArea


@export var _quest_manager: QuestManager
@export var _step_02_dialogue_event_01: DialogueEvent
@export var _default_dialogue_event: DialogueEvent

var _is_executing: bool


func _is_executable() -> bool:
	return not _is_executing


func _execute(target: CharacterBody2D) -> void:
	_is_executing = true
	match _quest_manager.get_curr_step():
		QuestManager.Steps.TWO:
			_execute_step_02(target)
		_:
			_execute_default_dialogue(target)


func _execute_step_02(target: CharacterBody2D) -> void:
	target.set_process_unhandled_input(false)
	DialogueManager.play(_step_02_dialogue_event_01)
	await _step_02_dialogue_event_01.finished
	# TODO Fight the blue parrot!
	print("Bucho wins!")
	# TODO Remove parrot tile. Add some blood below Bucho?
	_quest_manager.set_step_completed(QuestManager.Steps.TWO)
	target.set_process_unhandled_input(true)
	_is_executing = false


func _execute_default_dialogue(target: CharacterBody2D) -> void:
	target.set_process_unhandled_input(false)
	DialogueManager.play(_default_dialogue_event)
	await _default_dialogue_event.finished
	target.set_process_unhandled_input(true)
	_is_executing = false
