extends Node


signal finished

const DayExPlayer = preload("res://scenes/day_ex/player/day_ex_player.gd")
const DayExUi = preload("res://scenes/day_ex/ui/day_ex_ui.gd")
const Npc = preload("res://scenes/day_ex/npcs/npc.gd")
const DustCloudScene = preload("res://scenes/day_ex/player/dust_cloud.tscn")
const DummyPlayerScene = preload("res://scenes/day_ex/player/day_ex_player_dummy.tscn")

@export var _world: Node2D
@export var _bird_fighters_path: Array[NodePath]
@export var _rest_of_bird_gang_path: Array[NodePath]
@export var _last_duck_path: NodePath
@export var _boss_final_words: DialogueEvent
@export var _ending_dialogue: DialogueEvent

var _bird_fighters: Array[Npc]
var _rest_of_bird_gang: Array[Npc]
var _last_duck: Npc

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
	
	_last_duck = get_node(_last_duck_path) as Npc


func play() -> void:
	_player.set_process_unhandled_input(false)
	_player.set_physics_process(false)
	_player.set_process(false)
	
	await _suspend_hide_quest_indicator()
	await _suspend_boss_final_words()
	await _suspend_bucho_eats_fighters()
	await _suspend_bucho_scares_everyone_else()
	await _suspend_bucho_eats_rest_of_the_ducks()
	await _suspend_bucho_eats_last_duck()
	await _suspend_bucho_takes_flight()
	await _suspend_narrator()
	
	finished.emit()


func _suspend_hide_quest_indicator() -> void:
	_timer.start(0.5)
	await _timer.timeout
	_ui.show_quest_indicator(false)


func _suspend_boss_final_words() -> void:
	_timer.start(0.5)
	await _timer.timeout
	DialogueManager.play(_boss_final_words)
	await _boss_final_words.finished


func _suspend_bucho_eats_fighters() -> void:
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
	_last_duck.get_scared(true)


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


func _suspend_bucho_eats_last_duck() -> void:
	_timer.start(2.0)
	await _timer.timeout
	_ui.show_black_screen(true)
	_player.teleport(_last_duck.global_position, DayExPlayer.FacingDirection.DOWN)
	_last_duck.die()
	_last_duck = null
	_timer.start(0.5)
	await _timer.timeout
	_ui.show_black_screen(false)


func _suspend_bucho_takes_flight() -> void:
	_timer.start(2.5)
	await _timer.timeout
	_player.hide()
	_player.process_mode = Node.PROCESS_MODE_DISABLED
	var dummy := DummyPlayerScene.instantiate()
	dummy.global_position = _player.global_position
	dummy.z_index = 1
	var dust_cloud: GPUParticles2D = DustCloudScene.instantiate()
	dust_cloud.global_position = dummy.global_position
	dust_cloud.lifetime = 0.2
	dust_cloud.emitting = true
	dust_cloud.z_index = dummy.z_index
	_world.add_child(dummy)
	_world.add_child(dust_cloud)
	var tween: Tween = create_tween()
	var dummy_global_pos: Vector2 = dummy.global_position
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_QUINT)
	tween.tween_property(dummy, "global_position:y", dummy_global_pos.y - 125.0,
			2.0)
	tween.tween_interval(2.0)
	tween.set_trans(Tween.TRANS_LINEAR)
	tween.tween_property(dummy, "speed_scale", 4.0, 0.2)
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_QUINT)
	tween.tween_property(dummy, "global_position:x", dummy_global_pos.x + 140.0,
			1.0)
	await tween.finished
	dummy.queue_free()


func _suspend_narrator() -> void:
	_timer.start(2.0)
	await _timer.timeout
	_ui.show_black_screen(true)
	_timer.start(2.0)
	await _timer.timeout
	DialogueManager.play(_ending_dialogue)
	await _ending_dialogue.finished
	_timer.start(1.0)
	await _timer.timeout
