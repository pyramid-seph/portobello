@tool
extends CanvasLayer

signal battle_finished(success: bool)

const StatusDisplayManager = preload("res://scenes/day_ex/game/status_display_manager.gd")
const BattleNarrationBox = preload("res://scenes/day_ex/game/battle_narration_box.gd")
const Fighter = preload("res://scenes/day_ex/game/fighter.gd")
const PartyContainer = preload("res://scenes/day_ex/game/party_container.gd")
const ActionSelector = preload("res://scenes/day_ex/game/action_selector.gd")
const StatusDisplay = preload("res://scenes/day_ex/game/status_display.gd")
const StatusLabel = preload("res://scenes/day_ex/game/status_label.gd")

const PLAYER_PARTY_RES = preload("res://resources/instances/day_ex/parties/player_party.tres")

const FighterScene = preload("res://scenes/day_ex/game/fighter.tscn")


@export var _preview: bool = true:
	set(value):
		_preview = value
		_on_preview_set()

var _turn_order_manager: TurnOrderManager

@onready var _main_container: PanelContainer = $MainContainer
@onready var _narrator: BattleNarrationBox = %BattleNarrationBox
@onready var _enemy_party_container: PartyContainer = %EnemyPartyContainer
@onready var _player_party_container: PartyContainer = %PlayerPartyContainer
@onready var _player_commands_group_visibility: GroupVisibility = %PlayerCommandsGroupVisibility
@onready var _action_selector: ActionSelector = %ActionSelector
@onready var _info_label: Label = %InfoLabel
@onready var _status_display: StatusDisplay = %StatusDisplay
@onready var _status_label: StatusLabel = %StatusLabel


func _ready() -> void:
	_on_preview_set()
	
	if Engine.is_editor_hint():
		return
	
	_player_party_container.setup(PLAYER_PARTY_RES, null)
	var player_fighter: Fighter = _get_player()
	if player_fighter:
		player_fighter.displayed_status_changed.connect(
				_on_player_char_displayed_status_changed)
	
	_turn_order_manager = \
			TurnOrderManager.new(_player_party_container, _enemy_party_container)
	_main_container.visible = get_parent() == $/root


func start(enemy_party: BattleParty, background: Texture2D) -> void:
	TouchControllerManager.mode = TouchControllerManager.Mode.GAMEPLAY_RPG_BATTLE
	await _enter_battle_screen(enemy_party, background)
	#region TEST
	_action_selector.set_actions(
		[
			preload("res://resources/instances/day_ex/actions/ability_mesmer_eyes.tres"),
			preload("res://resources/instances/day_ex/actions/ability_scare.tres"),
			preload("res://resources/instances/day_ex/actions/attack_scratch.tres"),
			preload("res://resources/instances/day_ex/actions/attack_bite.tres"),
		]
	)
	var selected_target: Fighter = null
	while selected_target == null:
		_player_commands_group_visibility.referenced_controls_visibility = true
		_action_selector.call_deferred("grab_focus")
		var selected_command = await _action_selector.command_selected
		_enemy_party_container.call_deferred("grab_focus")
		_player_commands_group_visibility.referenced_controls_visibility = false
		# TODO Go back to command selection if the player does not select a target
		selected_target = await _enemy_party_container.target_selected
		if selected_target:
			var target = selected_target as Fighter
	#endregion TEST
	_exit_battle_screen()


func _setup_battle(enemy_party: BattleParty, background: Texture2D) -> void:
	_enemy_party_container.setup(enemy_party, background)
	_player_party_container.set_background(background)
	_turn_order_manager.on_battle_started()


func teardown() -> void:
	_turn_order_manager.on_battle_ended()
	_enemy_party_container.teardown()


func _enter_battle_screen(enemy_party: BattleParty, background: Texture2D) -> void:
	await TransitionPlayer.play_battle()
	_setup_battle(enemy_party, background)
	_main_container.show()
	await TransitionPlayer.play_battle_backwards()
	_narrator.say("RPG_BATTLE_NARRATION_BATTLE_STARTED")
	_narrator.call_deferred("grab_focus")
	await _narrator.acknowledged


func _exit_battle_screen() -> void:
	await TransitionPlayer.play_battle()
	teardown()
	_main_container.hide()
	await TransitionPlayer.play_battle_backwards()
	battle_finished.emit(true)


func _get_player() -> Fighter:
	return _player_party_container.get_member_at(0)


func _on_preview_set() -> void:
	if is_node_ready() and Engine.is_editor_hint():
		_main_container.visible = _preview


func _on_player_char_displayed_status_changed(
		new_status: StatusDisplayManager.Status) -> void:
	_status_display.display_status(new_status)
	_status_label.display_status(new_status)


func _on_player_commands_group_visibility_referenced_controls_visibility_changed() -> void:
	_player_party_container.visible = !_player_commands_group_visibility.referenced_controls_visibility


func _on_action_selector_current_info_changed(info_msg: String) -> void:
	if not is_node_ready():
		await ready
	_info_label.text = info_msg
