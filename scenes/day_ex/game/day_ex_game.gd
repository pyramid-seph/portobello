extends Node


const DayExUi = preload("res://scenes/day_ex/ui/day_ex_ui.gd")
const BattleStartSystem = preload("res://scenes/day_ex/game/battle_start_system.gd")
const BattleScreen = preload("res://scenes/day_ex/game/battle_screen.gd")

@export_group("Debug", "_debug")
@export var _debug_bg: Texture2D
@export var _debug_battle_party: BattleParty 
@export var _debug_skip_battles: bool:
	get: return OS.is_debug_build() and _debug_skip_battles

@onready var _battle_start_system: BattleStartSystem = $Systems/BattleStartSystem
@onready var _ui: DayExUi = $Interface/DayExUi
@onready var _player: CharacterBody2D = $World/TileMap/DayExPlayer
@onready var _battle_screen: BattleScreen = $BattleScreen


func _ready() -> void:
	TouchControllerManager.mode = TouchControllerManager.Mode.GAMEPLAY
	_start_game()


func _start_game() -> void:
	_player.set_process_unhandled_input(false)
	_ui.set_pause_menu_enabled(false)
	_ui.show_level_start()
	await _ui.start_level_finished
	_ui.set_pause_menu_enabled(true)
	_battle_start_system.reset(1.0)
	_player.set_process_unhandled_input(true)


func _on_battle_start_system_start_battle() -> void:
	if _debug_skip_battles:
		return
	
	_player.set_process_unhandled_input(false)
	await get_tree().physics_frame
	await get_tree().physics_frame
	$World/TileMap.process_mode = Node.PROCESS_MODE_DISABLED
	_battle_screen.start(_debug_battle_party, _debug_bg)


func _on_day_ex_ui_dialogue_started() -> void:
	_player.set_process_unhandled_input(false)


func _on_day_ex_ui_dialogue_finished() -> void:
	_player.set_process_unhandled_input(true)


func _on_day_ex_ui_dialogue_event_requested(event: String) -> void:
	print("dialogue requested this event to be run: ", event)


func _on_battle_screen_battle_finished(success: bool) -> void:
	if not success:
		return
	
	$World/TileMap.process_mode = Node.PROCESS_MODE_INHERIT
	_player.set_process_unhandled_input(true)
	_battle_start_system.reset()
