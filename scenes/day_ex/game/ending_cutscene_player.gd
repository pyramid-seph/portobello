extends Node


signal finished

const DayExPlayer = preload("res://scenes/day_ex/player/day_ex_player.gd")
const DayExUi = preload("res://scenes/day_ex/ui/day_ex_ui.gd")
const Npc = preload("res://scenes/day_ex/npcs/npc.gd")

@export var _bird_fighters_path: Array[NodePath]
@export var _rest_of_bird_gang_path: Array[NodePath]
@export var _hen_path: NodePath
@export var _ending_dialogue: DialogueEvent

var _bird_fighters: Array[Npc]
var _rest_of_bird_gang: Array[Npc]
var _hen: Npc

@onready var _ui: DayExUi = %DayExUi
@onready var _player: DayExPlayer = %DayExPlayer
@onready var _timer: Timer = $Timer


func _ready() -> void:
	_bird_fighters.resize(_bird_fighters_path.size())
	for i: int in _bird_fighters_path.size():
		_bird_fighters[i] = get_node(_bird_fighters_path[i]) as Npc
	
	_rest_of_bird_gang.resize(_rest_of_bird_gang_path.size())
	for i: int in _rest_of_bird_gang_path.size():
		_rest_of_bird_gang[i] = get_node(_rest_of_bird_gang_path[i]) as Npc
	
	_hen = get_node(_hen_path) as Npc


func play() -> void:
	_player.set_process_unhandled_input(false)
	_player.set_physics_process(false)
	_player.set_process(false)
	
	await _suspend_bucho_eats_fighters()
	await _suspend_bucho_scares_everyone_else()
	await _suspend_bucho_eats_rest_of_the_ducks()
	await _suspend_bucho_eats_hen()
	await _suspend_narrator()
	
	finished.emit()


func _suspend_bucho_eats_fighters() -> void:
	_timer.start(1.0)
	await _timer.timeout
	_ui.show_quest_indicator(false)
	_timer.start(1.0)
	await _timer.timeout
	_ui.show_black_screen(true)
	var last_eaten: Npc = _bird_fighters.pick_random()
	_player.teleport(last_eaten.global_position, DayExPlayer.FacingDirection.DOWN)
	for npc: Npc in _bird_fighters:
		npc.die()
	_bird_fighters.clear()
	_timer.start(0.5)
	await _timer.timeout
	_ui.show_black_screen(false)


func _suspend_bucho_scares_everyone_else() -> void:
	_timer.start(2.0)
	await _timer.timeout
	for npc: Npc in _rest_of_bird_gang:
		npc.get_scared(true)
	_hen.get_scared(true)


func _suspend_bucho_eats_rest_of_the_ducks() -> void:
	_timer.start(3.0)
	await _timer.timeout

	for npc: Npc in _rest_of_bird_gang:
		_ui.show_black_screen(true)
		_player.teleport(npc.global_position, DayExPlayer.FacingDirection.DOWN)
		npc.die()
		_timer.start(1.0)
		await _timer.timeout
		_ui.show_black_screen(false)
		_timer.start(1.0)
		await _timer.timeout
	_rest_of_bird_gang.clear()


func _suspend_bucho_eats_hen() -> void:
	_timer.start(2.0)
	await _timer.timeout
	_ui.show_black_screen(true)
	_player.teleport(_hen.global_position, DayExPlayer.FacingDirection.DOWN)
	_hen.die()
	_hen = null
	_timer.start(0.5)
	await _timer.timeout
	_ui.show_black_screen(false)


func _suspend_narrator() -> void:
	_timer.start(2.5)
	await _timer.timeout
	_ui.show_black_screen(true)
	_timer.start(2.0)
	await _timer.timeout
	DialogueManager.play(_ending_dialogue)
	await _ending_dialogue.finished
	_timer.start(1.0)
	await _timer.timeout
