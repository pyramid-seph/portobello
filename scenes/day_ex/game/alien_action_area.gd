extends ActionArea


@export var _quest_manager: QuestManager
@export var _step_04_dialogue_event_01: DialogueEvent

var _is_executing: bool


func _is_executable() -> bool:
	return not _is_executing


func _execute(target: CharacterBody2D) -> void:
	_is_executing = true
	if _quest_manager.get_curr_step() == QuestManager.Steps.FOUR:
		_execute_step_04(target)


func _execute_step_04(target: CharacterBody2D) -> void:
	target.set_process_unhandled_input(false)
	DialogueManager.play(_step_04_dialogue_event_01)
	await _step_04_dialogue_event_01.finished
	# TODO Fight the alien!
	print("Bucho wins!")
	target.set_process_unhandled_input(true)
	_quest_manager.set_step_completed(QuestManager.Steps.FOUR)
	_is_executing = false
