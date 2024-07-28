@tool
extends CanvasLayer

signal battle_finished(success: bool)

const StatusDisplayManager = preload("res://scenes/day_ex/game/status_display_manager.gd")
const BattleNarrationBox = preload("res://scenes/day_ex/game/battle_narration_box.gd")
const Fighter = preload("res://scenes/day_ex/game/fighter.gd")
const BattlefieldSide = preload("res://scenes/day_ex/game/battlefield_side.gd")
const ActionSelector = preload("res://scenes/day_ex/game/action_selector.gd")
const StatusDisplay = preload("res://scenes/day_ex/game/status_display.gd")
const StatusLabel = preload("res://scenes/day_ex/game/status_label.gd")

const PLAYER_PARTY_RES = preload("res://resources/instances/day_ex/parties/player_party.tres")

const FighterScene = preload("res://scenes/day_ex/game/fighter.tscn")


@export var _preview: bool = true:
	set(value):
		_preview = value
		_on_preview_set()

var _battle_manager: BattleManager

@onready var _main_container: PanelContainer = $MainContainer
@onready var _narrator: BattleNarrationBox = %BattleNarrationBox
@onready var _enemy_side: BattlefieldSide = %EnemyBattlefieldSide
@onready var _player_side: BattlefieldSide = %PlayerBattlefieldSide
@onready var _player_commands_group_visibility: GroupVisibility = %PlayerCommandsGroupVisibility
@onready var _action_selector: ActionSelector = %ActionSelector
@onready var _info_label: Label = %InfoLabel
@onready var _status_display: StatusDisplay = %StatusDisplay
@onready var _status_label: StatusLabel = %StatusLabel
@onready var _level_label: Label = %LevelLabel
@onready var _hp_label: Label = %HPLabel
@onready var _mp_label: Label = %MPLabel


func _ready() -> void:
	_on_preview_set()
	
	if Engine.is_editor_hint():
		return
	
	_setup_player()
	_battle_manager = BattleManager.new(_player_side, _enemy_side)
	_main_container.visible = get_parent() == $/root


func start(enemy_party: BattleParty, background: Texture2D) -> void:
	TouchControllerManager.mode = TouchControllerManager.Mode.GAMEPLAY_RPG_BATTLE
	await _enter_battle_screen(enemy_party, background)
	var result: BattleManager.Result = await _battle_manager.start_battle()
	print("Battle Result: ", result)
	if result.is_game_over():
		# TODO Narrate Game over and wait for acknowledgement
		# TODO Return to title screen
		_exit_battle_screen() # This is just until game over is implemented
	else:
		# TODO Narrate enemy party defeated!
		var exp_gained: int = result.get_exp_gained()
		var stats_diff: Stats = \
				_get_player().get_stats_manager().gain_experience(exp_gained)
		# TODO Narrate level ups and stat gains if any
		var treats_obtained: int = result.get_obtained_scraps()
		# TODO Narrate obtained scraps (if any)
		# TODO Store in memory current number of scraps
		_exit_battle_screen()


func _setup_player() -> void:
	_player_side.setup(PLAYER_PARTY_RES, null)
	var player_fighter: Fighter = _get_player()
	if player_fighter:
		player_fighter.displayed_status_changed.connect(
				_on_player_char_displayed_status_changed)
		var stats_manager: StatsManager = player_fighter.get_stats_manager()
		stats_manager.curr_level_changed.connect(_on_player_level_changed)
		stats_manager.curr_hp_changed.connect(_on_player_hp_changed)
		stats_manager.curr_mp_changed.connect(_on_player_mp_changed)
		_on_player_level_changed()
		player_fighter.install_brain(PlayerFighterBrain.new(_action_selector))


func _setup_battle(enemy_party: BattleParty, background: Texture2D) -> void:
	_enemy_side.setup(enemy_party, background)
	_player_side.set_background(background)


func teardown() -> void:
	_enemy_side.teardown()


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
	return _player_side.get_member_at(0)


func _on_preview_set() -> void:
	if is_node_ready() and Engine.is_editor_hint():
		_main_container.visible = _preview


func _on_player_char_displayed_status_changed(
		new_status: StatusDisplayManager.Status) -> void:
	_status_display.display_status(new_status)
	_status_label.display_status(new_status)


func _on_player_hp_changed() -> void:
	var player: Fighter = _get_player()
	if player:
		var stats_manager: StatsManager = player.get_stats_manager()
		_hp_label.text = "HP: %s/%s" % \
				[stats_manager.get_curr_hp(), stats_manager.get_max_hp()]


func _on_player_mp_changed() -> void:
	var player: Fighter = _get_player()
	var stats_manager: StatsManager = player.get_stats_manager()
	_mp_label.text = "MP: %s/%s" % \
			[stats_manager.get_curr_mp(), stats_manager.get_max_mp()]


func _on_player_level_changed() -> void:
	var player: Fighter = _get_player()
	var stats_manager: StatsManager = player.get_stats_manager()
	_level_label.text = "%s lvl %s" % \
			[player.get_full_name(), stats_manager.get_current_level()]
	_on_player_hp_changed()
	_on_player_mp_changed()


func _on_player_commands_group_visibility_referenced_controls_visibility_changed() -> void:
	_player_side.visible = !_player_commands_group_visibility.referenced_controls_visibility


func _on_action_selector_current_info_changed(info_msg: String) -> void:
	if not is_node_ready():
		await ready
	_info_label.text = info_msg


func _on_action_selector_focus_entered() -> void:
	if is_node_ready():
		_player_commands_group_visibility.referenced_controls_visibility = true


func _on_action_selector_command_selected(_command: BattleCommand) -> void:
	if is_node_ready():
		_player_commands_group_visibility.referenced_controls_visibility = false
