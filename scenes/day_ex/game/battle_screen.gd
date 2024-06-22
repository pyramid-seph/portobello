@tool
extends CanvasLayer

signal battle_finished(success: bool)

const BattleNarrationBox = preload("res://scenes/day_ex/game/battle_narration_box.gd")
const Fighter = preload("res://scenes/day_ex/game/fighter.gd")
const PartyContainer = preload("res://scenes/day_ex/game/party_container.gd")
const ActionSelector = preload("res://scenes/day_ex/game/action_selector.gd")

const player_data = preload("res://resources/instances/day_ex/chars/player.tres")

const CommandEat = preload("res://resources/instances/day_ex/actions/command_eat.tres")
const CommandCure = preload("res://resources/instances/day_ex/actions/command_cure.tres")

const FighterScene = preload("res://scenes/day_ex/game/fighter.tscn")


@export var _preview: bool = true:
	set(value):
		_preview = value
		_on_preview_set()

var _cur_turn: int = -1
var _sorted_by_turn: Array[Fighter]

@onready var _panel_container: PanelContainer = $PanelContainer
@onready var _narrator: BattleNarrationBox = %BattleNarrationBox
@onready var _enemy_party_container: PartyContainer = %EnemyPartyContainer
@onready var _player_char: Fighter = %PlayerChar
@onready var _player_commands_group_visibility: GroupVisibility = %PlayerCommandsGroupVisibility
@onready var _action_selector: ActionSelector = %ActionSelector
@onready var _info_label: Label = %InfoLabel


func _ready() -> void:
	_on_preview_set()
	
	if Engine.is_editor_hint():
		return
	
	_player_char.set_fighter_data(player_data)
	_panel_container.visible = get_parent() == $/root


func start(enemy_party: BattleParty, background: Texture2D) -> void:
	_cur_turn = -1
	_sorted_by_turn.clear()
	
	await _enter_battle_screen(enemy_party, background)

	for i in 3:
		_cur_turn = wrapi(_cur_turn + 1, 0, _sorted_by_turn.size())
		while _sorted_by_turn[_cur_turn].is_dead():
			_cur_turn = wrapi(_cur_turn + 1, 0, _sorted_by_turn.size())
		await _sorted_by_turn[_cur_turn].take_turn()
		i += 1
	_exit_battle_screen()


func _enter_battle_screen(enemy_party: BattleParty, background: Texture2D) -> void:
	await TransitionPlayer.play_battle()
	_enemy_party_container.setup(enemy_party, background)
	# TODO setup player party
	
	_sorted_by_turn = _enemy_party_container.get_members()
	_sorted_by_turn.append(_player_char)
	update_turns()
	
	_panel_container.show()
	await TransitionPlayer.play_battle_backwards()
	_narrator.say("RPG_BATTLE_NARRATION_BATTLE_STARTED")
	_narrator.call_deferred("grab_focus")
	await _narrator.acknowledged


func update_turns() -> void:
	_sorted_by_turn.sort_custom(func(a: Fighter, b: Fighter):
			# TODO If everyone has the same speed, let the player take their turn first
			var a_stats = a.get_stats_manager()
			var b_stats = b.get_stats_manager()
			return a_stats.get_spd() > b_stats.get_spd())


func _exit_battle_screen() -> void:
	await TransitionPlayer.play_battle()
	teardown()
	_panel_container.hide()
	await TransitionPlayer.play_battle_backwards()
	battle_finished.emit(true)


func teardown() -> void:
	_enemy_party_container.teardown()


func _on_preview_set() -> void:
	if is_node_ready() and Engine.is_editor_hint():
		_panel_container.visible = _preview


func _on_player_commands_group_visibility_referenced_controls_visibility_changed() -> void:
	_player_char.visible = !_player_commands_group_visibility.referenced_controls_visibility


func _on_action_selector_current_option_changed(info_msg: String) -> void:
	_info_label.text = info_msg
