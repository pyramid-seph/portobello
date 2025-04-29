extends ActionArea

const SFX_DOOR_OPEN = preload("res://audio/sfx/sfx_day_ex_door_open.wav")

@export var _quest_manager: QuestManager
@export var _living_room_door_path: NodePath
@export var _kitchen_door_path: NodePath
@export var _step_01_dialogue_event_01: DialogueEvent
@export var _step_01_dialogue_event_02: DialogueEvent
@export var _step_03_dialogue_event_01: DialogueEvent
@export var _step_03_dialogue_event_02: DialogueEvent
@export var _default_dialogue_event: DialogueEvent

var _is_executing: bool

@onready var _timer: Timer = $Timer


func _is_executable() -> bool:
	return not _is_executing


func _execute(target: CharacterBody2D) -> void:
	_is_executing = true
	match _quest_manager.get_curr_step():
		QuestManager.Steps.ONE:
			_execute_step_01(target)
		QuestManager.Steps.THREE:
			_execute_step_03(target)
		_:
			_execute_default_dialogue(target)


func _execute_step_01(target: CharacterBody2D) -> void:
	target.set_process_unhandled_input(false)
	DialogueManager.play(_step_01_dialogue_event_01)
	await _step_01_dialogue_event_01.finished
	await TransitionPlayer.play_default()
	await SoundManager.play_sound(SFX_DOOR_OPEN).finished
	if _living_room_door_path:
		var door: Node2D = get_node_or_null(_living_room_door_path)
		if door:
			door.queue_free()
	_timer.start(1.0)
	await _timer.timeout
	await TransitionPlayer.play_default_backwards()
	DialogueManager.play(_step_01_dialogue_event_02)
	await _step_01_dialogue_event_02.finished
	_quest_manager.set_step_completed(QuestManager.Steps.ONE)
	target.set_process_unhandled_input(true)
	_is_executing = false


func _execute_step_03(target: CharacterBody2D) -> void:
	target.set_process_unhandled_input(false)
	DialogueManager.play(_step_03_dialogue_event_01)
	await _step_03_dialogue_event_01.finished
	await TransitionPlayer.play_default()
	await SoundManager.play_sound(SFX_DOOR_OPEN).finished
	if _kitchen_door_path:
		var door: Node2D = get_node_or_null(_kitchen_door_path)
		if door:
			door.queue_free()
	_timer.start(1.0)
	await _timer.timeout
	await TransitionPlayer.play_default_backwards()
	DialogueManager.play(_step_03_dialogue_event_02)
	await _step_03_dialogue_event_02.finished
	_quest_manager.set_step_completed(QuestManager.Steps.THREE)
	target.set_process_unhandled_input(true)
	_is_executing = false


func _execute_default_dialogue(target: CharacterBody2D) -> void:
	target.set_process_unhandled_input(false)
	DialogueManager.play(_default_dialogue_event)
	await _default_dialogue_event.finished
	target.set_process_unhandled_input(true)
	_is_executing = false
