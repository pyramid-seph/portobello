extends Node


const DayExUi = preload("res://scenes/day_ex/ui/day_ex_ui.gd")
const BattleStartSystem = preload("res://scenes/day_ex/game/battle_start_system.gd")

@export_group("Debug", "_debug")
@export var _debug_skip_battles: bool:
	get: return OS.is_debug_build() and _debug_skip_battles

@onready var _battle_start_system: BattleStartSystem = $Systems/BattleStartSystem
@onready var _ui: DayExUi = $Interface/DayExUi


func _ready() -> void:
	TouchControllerManager.mode = TouchControllerManager.Mode.GAMEPLAY
	_start_game()


func _start_game() -> void:
	_ui.show_level_start()
	await _ui.start_level_finished
	_battle_start_system.reset(5.0)


func _on_battle_start_system_start_battle() -> void:
	if not _debug_skip_battles:
		# disable all world processing
		# Play some neat effect
		# Start battle state and give control to the battle manager
		print("BATTLE!")
	_battle_start_system.reset(3.0)
