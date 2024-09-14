extends ActionArea


signal start_battle(background: Texture2D, party: BattleParty)

const BattleScreen = preload("res://scenes/day_ex/game/battle_screen.gd")

@export var _battle_screen_path: NodePath
@export var _quest_manager: QuestManager
@export var _step_04_dialogue_event_01: DialogueEvent

@export_group("Battle Config")
@export var _background: Texture2D
@export var _party: BattleParty
@export var _ending_cutscene_player: Node

var _is_executing: bool
var _battle_screen: BattleScreen


func _ready() -> void:
	super()
	_battle_screen = get_node(_battle_screen_path) as BattleScreen


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
	_battle_screen.start(_party, _background, true)
	var success: bool = await _battle_screen.battle_finished
	if success:
		target.set_process_unhandled_input(true)
		_ending_cutscene_player.play()
		await _ending_cutscene_player.finished
		_quest_manager.set_step_completed(QuestManager.Steps.FOUR)
	_is_executing = false
