extends Node


const Day01Player = preload("res://scenes/day_01/player/day_01_player.gd")

const DAY_01_BGM_STREAM = preload("res://resources/instances/day_01_bgm_stream.tres")

var _playback: AudioStreamPlaybackInteractive

@onready var player: Day01Player = %Day01Player


func _ready() -> void:
	player.started_moving.connect(_on_day_01_player_started_moving)


func _exit_tree() -> void:
	stop_music()


func play_level_music() -> void:
	await _suspend_ensure_playing()
	if player.is_awaiting_first_movement():
		_switch_to_intro()
	else:
		_switch_to_main()


func play_success_music() -> void:
	await _suspend_ensure_playing()
	_switch_to_success()


func stop_music() -> void:
	_switch_to_intro()
	_playback = null
	
	if SoundManager.is_music_playing(DAY_01_BGM_STREAM):
		SoundManager.stop_music()


func _suspend_ensure_playing() -> void:
	if SoundManager.is_music_playing(DAY_01_BGM_STREAM):
		return
	
	var audio_player: AudioStreamPlayer = \
			SoundManager.play_music(DAY_01_BGM_STREAM)
	# Waiting for the next process frame so I don't get an error 
	# when trying to access the AudioStreamPlaybackInteractive.
	await get_tree().process_frame
	if SoundManager.is_music_playing(DAY_01_BGM_STREAM):
		_playback = \
				audio_player.get_stream_playback() as AudioStreamPlaybackInteractive


func _switch_to_intro() -> void:
	if _playback:
		_playback.switch_to_clip_by_name(&"intro")


func _switch_to_main() -> void:
	if _playback:
		_playback.switch_to_clip_by_name(&"main")


func _switch_to_success() -> void:
	if _playback:
		_playback.switch_to_clip_by_name(&"success")


func _on_day_01_player_started_moving() -> void:
	_switch_to_main()
