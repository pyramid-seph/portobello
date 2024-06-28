extends Node


const DayExUi = preload("res://scenes/day_ex/ui/day_ex_ui.gd")
const RandomBattleSystem = preload("res://scenes/day_ex/game/random_battle_system.gd")
const BattleScreen = preload("res://scenes/day_ex/game/battle_screen.gd")

@export_group("Debug", "_debug")
@export var _debug_skip_random_battles: bool:
	get:
		return OS.is_debug_build() and _debug_skip_random_battles

@onready var _random_battle_system: RandomBattleSystem = %RandomBattleSystem
@onready var _player: CharacterBody2D = $World/TileMap/DayExPlayer
@onready var _battle_screen: BattleScreen = $BattleScreen
@onready var _ui: DayExUi = $Interface/DayExUi


func _ready() -> void:
	TouchControllerManager.mode = TouchControllerManager.Mode.GAMEPLAY_RPG_WORLD
	_start_game()


func _start_game() -> void:
	_player.set_process_unhandled_input(false)
	_ui.set_pause_menu_enabled(false)
	_ui.show_level_start()
	await _ui.start_level_finished
	_ui.set_pause_menu_enabled(true)
	_random_battle_system.reset()
	_player.set_process_unhandled_input(true)


func _start_battle(enemy_party: BattleParty, background: Texture2D) -> void:
	_ui.set_pause_menu_enabled(false)
	_player.set_process_unhandled_input(false)
	await get_tree().physics_frame
	await get_tree().physics_frame
	$World/TileMap.process_mode = Node.PROCESS_MODE_DISABLED
	_battle_screen.start(enemy_party, background)


func _on_day_ex_ui_dialogue_started() -> void:
	_player.set_process_unhandled_input(false)


func _on_day_ex_ui_dialogue_finished() -> void:
	_player.set_process_unhandled_input(true)


func _on_day_ex_ui_dialogue_event_requested(event: String) -> void:
	print("dialogue requested this event to be run: ", event)


func _on_battle_screen_battle_finished(success: bool) -> void:
	if success:
		TouchControllerManager.mode = TouchControllerManager.Mode.GAMEPLAY_RPG_WORLD
		_ui.set_pause_menu_enabled(true)
		$World/TileMap.process_mode = Node.PROCESS_MODE_INHERIT
		_player.set_process_unhandled_input(true)
		_random_battle_system.reset()
	else:
		Game.start(Game.Minigame.TITLE_SCREEN)


func _on_random_battle_system_start_battle(
		enemy_party: BattleParty, background: Texture2D) -> void:
	if not _debug_skip_random_battles:
		_start_battle(enemy_party, background)
