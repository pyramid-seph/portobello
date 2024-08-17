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

const TRANSITION_DELAY: float = 1.0

@export var _preview: bool = true:
	set(value):
		_preview = value
		_on_preview_set()

var _battle_manager: BattleManager

@onready var _transition_delay_timer: Timer = $TransitionDelayTimer
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
@onready var _treat_count: Label = %TreatCount


func _ready() -> void:
	_on_preview_set()
	
	if Engine.is_editor_hint():
		return
	
	
	
	
	_enemy_side._narrator = _narrator
	_player_side._narrator = _narrator
	
	
	
	
	
	
	_setup_player()
	_battle_manager = BattleManager.new(_player_side, _enemy_side)
	_main_container.visible = get_parent() == $/root


func start(enemy_party: BattleParty, background: Texture2D, 
		is_boss_battle: bool) -> void:
	TouchControllerManager.mode = TouchControllerManager.Mode.GAMEPLAY_RPG_BATTLE
	await _enter_battle_screen(enemy_party, background)
	var result: BattleManager.Result = \
			await _battle_manager.start_battle(is_boss_battle)
	_on_battle_finished(result)


func _setup_player() -> void:
	_player_side.setup(PLAYER_PARTY_RES)
	var player_fighter: Fighter = _get_player()
	if player_fighter:
		var status_display_manager: StatusDisplayManager = \
				player_fighter.get_status_display_manager()
		player_fighter.scraps_qty_changed.connect(_on_scraps_qty_changed)
		status_display_manager.displayed_status_changed.connect(
				_on_player_displayed_status_changed)
		var stats_manager: StatsManager = player_fighter.get_stats_manager()
		stats_manager.curr_level_changed.connect(_on_player_level_changed)
		stats_manager.curr_hp_changed.connect(_on_player_hp_changed)
		stats_manager.curr_mp_changed.connect(_on_player_mp_changed)
		_on_player_level_changed()
		_on_scraps_qty_changed()
		_on_player_displayed_status_changed(
				status_display_manager.get_displayed_status())
		player_fighter.install_brain(PlayerFighterBrain.new(_action_selector))


func _setup_battle(enemy_party: BattleParty, background: Texture2D) -> void:
	_enemy_side.setup(enemy_party, background)
	_player_side.set_background(background)
	_make_them_enter_battlefield(_player_side.get_members())
	_make_them_enter_battlefield(_enemy_side.get_members())


func _on_battle_finished(result: BattleManager.Result) -> void:
	if result.is_game_over():
		await _narrator.say_and_wait_until_read(
				"RPG_BATTLE_NARRATION_BATTLE_FAILURE")
		_transition_delay_timer.start(TRANSITION_DELAY)
		await _transition_delay_timer.timeout
		battle_finished.emit(false)
	else:
		await _narrator.say_and_wait_until_read(
				"RPG_BATTLE_NARRATION_BATTLE_SUCCESS")
		var scraps_obtained: int = result.get_obtained_scraps()
		var exp_gained: int = result.get_exp_gained()
		if exp_gained > 0:
			var msg_string: String = "RPG_BATTLE_NARRATION_LOOT_EXP_ONE"
			if exp_gained > 1:
				msg_string = "RPG_BATTLE_NARRATION_LOOT_EXP_MANY"
			await _narrator.say_and_wait_until_read(
					msg_string, { "exp": exp_gained })
		var stats_manager: StatsManager = _get_player().get_stats_manager()
		var stats_diff: Stats = stats_manager.gain_experience(exp_gained)
		await _wait_level_up_narration_finished(stats_manager, stats_diff)
		if scraps_obtained > 0:
			_get_player().scraps += scraps_obtained
			var msg_string: String = "RPG_BATTLE_NARRATION_LOOT_SCRAPS_ONE"
			if exp_gained > 1:
				msg_string = "RPG_BATTLE_NARRATION_LOOT_SCRAPS_MANY"
			await _narrator.say_and_wait_until_read(
					msg_string, { "scraps": scraps_obtained })
		_transition_delay_timer.start(TRANSITION_DELAY)
		await _transition_delay_timer.timeout
		_exit_battle_screen()


func _enter_battle_screen(enemy_party: BattleParty, background: Texture2D) -> void:
	await TransitionPlayer.play_battle()
	_setup_battle(enemy_party, background)
	_main_container.show()
	_narrator.say("RPG_BATTLE_NARRATION_BATTLE_STARTED")
	await TransitionPlayer.play_battle_backwards()
	await _narrator.wait_until_read()


func _make_them_enter_battlefield(fighters: Array[Fighter]) -> void:
	for fighter: Fighter in fighters:
		fighter.enter_battlefield()


func _teardown() -> void:
	_enemy_side.teardown()


func _exit_battle_screen() -> void:
	await TransitionPlayer.play_battle()
	_teardown()
	_main_container.hide()
	await TransitionPlayer.play_battle_backwards()
	battle_finished.emit(true)


func _get_player() -> Fighter:
	return _player_side.get_member_at(0)


func _wait_level_up_narration_finished(
		stats_manager: StatsManager, stats_diff: Stats) -> void:
	if stats_diff.get_level() > 0:
		var new_level: int = stats_manager.get_current_level()
		await _narrator.say_and_wait_until_read(
				"RPG_BATTLE_NARRATION_LEVEL_UP", { "level": new_level })
	else:
		return
	
	if stats_diff.get_max_hp() > 0:
		var points: int = stats_manager.get_max_hp()
		await _narrator.say_and_wait_until_read(
				"RPG_BATTLE_NARRATION_LEVEL_UP_MAX_HP_UP", { "points": points })
	
	if stats_diff.get_max_mp() > 0:
		var points: int = stats_manager.get_max_mp()
		await _narrator.say_and_wait_until_read(
				"RPG_BATTLE_NARRATION_LEVEL_UP_MAX_MP_UP", { "points": points })
	
	if stats_diff.get_atk() > 0:
		var points: int = stats_diff.get_atk()
		await _narrator.say_and_wait_until_read(
				"RPG_BATTLE_NARRATION_LEVEL_UP_ATTACK_UP", { "points": points })
	
	if stats_diff.get_def() > 0:
		var points: int = stats_diff.get_def()
		await _narrator.say_and_wait_until_read(
				"RPG_BATTLE_NARRATION_LEVEL_UP_DEFENSE_UP", { "points": points })
	
	if stats_diff.get_spd() > 0:
		var points: int = stats_diff.get_spd()
		await _narrator.say_and_wait_until_read(
				"RPG_BATTLE_NARRATION_LEVEL_UP_SPEED_UP", { "points": points })
	
	if stats_diff.get_agi() > 0:
		var points: int = stats_diff.get_agi()
		await _narrator.say_and_wait_until_read(
				"RPG_BATTLE_NARRATION_LEVEL_UP_AGILITY_UP", { "points": points })
	
	if stats_diff.get_lck() > 0:
		var points: int = stats_diff.get_lck()
		await _narrator.say_and_wait_until_read(
				"RPG_BATTLE_NARRATION_LEVEL_UP_LUCK_UP", { "points": points })


func _on_preview_set() -> void:
	if is_node_ready() and Engine.is_editor_hint():
		_main_container.visible = _preview


func _on_player_displayed_status_changed(
		new_status: StatusDisplayManager.Status) -> void:
	_status_display.display_status(new_status)
	_status_label.display_status(new_status)


func _on_player_hp_changed() -> void:
	var player: Fighter = _get_player()
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


func _on_scraps_qty_changed() -> void:
	var player: Fighter = _get_player()
	_treat_count.text = str(player.scraps)


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
