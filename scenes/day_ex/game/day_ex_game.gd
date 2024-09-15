extends Node


const DayExUi = preload("res://scenes/day_ex/ui/day_ex_ui.gd")
const RandomBattleSystem = preload("res://scenes/day_ex/game/random_battle_system.gd")
const BattleScreen = preload("res://scenes/day_ex/game/battle_screen.gd")

@export_group("Debug", "_debug")
@export var _debug_skip_random_battles: bool:
	get:
		return OS.is_debug_build() and _debug_skip_random_battles

@onready var _quest_manager: QuestManager = $Systems/QuestManager
@onready var _random_battle_system: RandomBattleSystem = %RandomBattleSystem
@onready var _player: CharacterBody2D = $World/TileMap/DayExPlayer
@onready var _battle_screen: BattleScreen = $BattleScreen
@onready var _ui: DayExUi = %DayExUi
@onready var _field: Node2D = $World/TileMap
@onready var _timer: Timer = $Timer


func _ready() -> void:
	TouchControllerManager.mode = TouchControllerManager.Mode.GAMEPLAY_RPG_WORLD
	_start_game()


func _start_game() -> void:
	_on_quest_manager_progress_made()
	_player.set_process_unhandled_input(false)
	_ui.hide_quest_indicator()
	_ui.set_pause_menu_enabled(false)
	_ui.show_level_start()
	await _ui.start_level_finished
	_ui.set_pause_menu_enabled(true)
	_random_battle_system.reset()
	_player.set_process_unhandled_input(true)
	_ui.show_quest_indicator(true)


func _start_battle(enemy_party: BattleParty, background: Texture2D, 
		is_boss_battle: bool = false) -> void:
	_player.set_process_unhandled_input(false)
	await get_tree().physics_frame
	await get_tree().physics_frame
	_battle_screen.start(enemy_party, background, is_boss_battle)


func _on_battle_screen_battle_starting() -> void:
	_field.process_mode = Node.PROCESS_MODE_DISABLED
	_ui.set_pause_menu_enabled(false)


func _on_battle_screen_battle_finished(success: bool, is_boss_battle: bool) -> void:
	if success:
		if not _quest_manager.is_quest_completed():
			TouchControllerManager.mode = \
					TouchControllerManager.Mode.GAMEPLAY_RPG_WORLD
			_ui.set_pause_menu_enabled(true)
			_field.process_mode = Node.PROCESS_MODE_INHERIT
			_player.set_process_unhandled_input(!is_boss_battle)
			_random_battle_system.reset()
	else:
		Game.start(Game.Minigame.TITLE_SCREEN)

 
func _on_random_battle_system_start_battle(
		enemy_party: BattleParty, background: Texture2D) -> void:
	if _debug_skip_random_battles:
		_random_battle_system.reset()
	else:
		_start_battle(enemy_party, background)


func _on_quest_manager_progress_made() -> void:
	if _quest_manager.is_quest_completed():
		_ui.set_pause_menu_enabled(false)
		_ui.show_level_completed_screen(true)
		_timer.start(3.2)
		await _timer.timeout
		Game.start(Game.Minigame.TITLE_SCREEN)
	else:
		var quest_msg: String = \
				"QUEST_STEP_%d" % _quest_manager.get_curr_step()
		_ui.set_step_text(quest_msg)
