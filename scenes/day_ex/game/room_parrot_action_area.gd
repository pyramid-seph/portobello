extends ActionArea


const BattleScreen = preload("res://scenes/day_ex/game/battle_screen.gd")

@export var _battle_screen_path: NodePath
@export var _quest_manager: QuestManager
@export var _step_02_dialogue_event_01: DialogueEvent
@export var _step_02_dialogue_event_02: DialogueEvent
@export var _default_dialogue_event: DialogueEvent
@export var _blood_splat: Node2D
@export var _parrot: Node2D

@export_group("Battle Config")
@export var _background: Texture2D
@export var _party: BattleParty

var _is_executing: bool
var _battle_screen: BattleScreen

@onready var _timer: Timer = $Timer


func _ready() -> void:
	super()
	_battle_screen = get_node(_battle_screen_path) as BattleScreen


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
	_battle_screen.start(_party, _background, true)
	var success: bool = await _battle_screen.battle_finishing
	if success:
		_parrot.hide()
		_blood_splat.show()
	await _battle_screen.battle_finished
	if success:
		_timer.start(1.0)
		await _timer.timeout
		DialogueManager.play(_step_02_dialogue_event_02)
		await _step_02_dialogue_event_02.finished
		_quest_manager.set_step_completed(QuestManager.Steps.TWO)
		target.set_process_unhandled_input(true)
	_is_executing = false


func _execute_default_dialogue(target: CharacterBody2D) -> void:
	target.set_process_unhandled_input(false)
	DialogueManager.play(_default_dialogue_event)
	await _default_dialogue_event.finished
	target.set_process_unhandled_input(true)
	_is_executing = false
