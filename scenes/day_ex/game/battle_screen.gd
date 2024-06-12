@tool
extends CanvasLayer

signal battle_finished(success: bool)

const BattleNarrationBox = preload("res://scenes/day_ex/game/battle_narration_box.gd")
const RpgEnemy = preload("res://scenes/day_ex/game/rpg_enemy.gd")
const EnemyPartyContainer = preload("res://scenes/day_ex/game/enemy_party_container.gd")
const BattleManager = preload("res://scenes/day_ex/game/battle_manager.gd")
const ActionSelector = preload("res://scenes/day_ex/game/action_selector.gd")

const CommandEat = preload("res://resources/instances/day_ex/actions/command_eat.tres")
const CommandCure = preload("res://resources/instances/day_ex/actions/command_cure.tres")

const EnemyScene = preload("res://scenes/day_ex/game/rpg_enemy.tscn")


@export var _preview: bool = true:
	set(value):
		_preview = value
		_on_preview_set()

@onready var _battle_manager: BattleManager = $BattleManager
@onready var _panel_container: PanelContainer = $PanelContainer
@onready var _battle_narration_box: BattleNarrationBox = %BattleNarrationBox
@onready var _enemy_party_container: EnemyPartyContainer = %EnemyPartyContainer
@onready var _player_char: TextureRect = %PlayerChar
@onready var _player_commands_group_visibility: GroupVisibility = %PlayerCommandsGroupVisibility
@onready var _action_selector: ActionSelector = %ActionSelector
@onready var _info_label: Label = %InfoLabel
@onready var _timer: Timer = $Timer


func _ready() -> void:
	_on_preview_set()
	
	if Engine.is_editor_hint():
		return
	
	_panel_container.visible = get_parent() == $/root


func start(enemy_party: BattleParty, background: Texture2D) -> void:
	_enter_battle_screen(enemy_party, background)
	_timer.start(1)
	await _timer.timeout
	_action_selector.call_deferred("grab_focus")


func _enter_battle_screen(enemy_party: BattleParty, background: Texture2D) -> void:
	await TransitionPlayer.play_battle()
	_enemy_party_container.setup(enemy_party, background)
	_panel_container.show()
	_battle_narration_box.say("RPG_BATTLE_NARRATION_BATTLE_STARTED")
	await TransitionPlayer.play_battle_backwards()


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
