extends Node


const Day01Player = preload("res://scenes/day_01/player/day_01_player.gd")

const BGM_DAY_01_INTRO = preload("res://audio/bgm/bgm_day_01_intro.wav")
const BGM_DAY_01_INTRO_BACKWARD = preload("res://audio/bgm/bgm_day_01_intro_backward.wav")
const BGM_DAY_01_MAIN = preload("res://audio/bgm/remaki_0.wav")
const BGM_DAY_01_SUCCESS_FANFARE = preload("res://audio/bgm/bgm_day_01_success_fanfare.wav")

@onready var _player: Day01Player = %Day01Player


func _ready() -> void:
	_player.started_moving.connect(_on_day_01_player_started_moving)


func _exit_tree() -> void:
	stop_music()


func play_level_music() -> void:
	if _player.is_awaiting_first_movement():
		_switch_to_intro()
	else:
		_switch_to_main()


func play_success_music() -> void:
	_switch_to_success()


func stop_music() -> void:
	SoundManager.stop_music()


func _switch_to_intro() -> void:
	if _player.inverted_controls:
		SoundManager.play_music(BGM_DAY_01_INTRO_BACKWARD)
	else:
		SoundManager.play_music(BGM_DAY_01_INTRO)


func _switch_to_main() -> void:
	SoundManager.play_music(BGM_DAY_01_MAIN)


func _switch_to_success() -> void:
	SoundManager.play_music(BGM_DAY_01_SUCCESS_FANFARE)


func _on_day_01_player_started_moving() -> void:
	_switch_to_main()
