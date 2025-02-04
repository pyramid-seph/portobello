extends Node


const BGM_EXPLORATION = preload("res://audio/bgm/remaki_0.wav")
const BGM_BATTLE = preload("res://audio/bgm/remaki_1.wav")
const BGM_SUCCESS = preload("res://audio/bgm/bgm_level_test.wav")
const BGM_GAME_OVER = preload("res://audio/bgm/bgm_boss_test.wav")

var _exploration_bgm_position: float
var _exploration_bgm_audio_player: AudioStreamPlayer


func _exit_tree() -> void:
	SoundManager.stop_music()


func stop_music() -> void:
	SoundManager.stop_music()


func play_exploration_bgm() -> void:
	_switch_to_exploration_stream()


func play_normal_battle_bgm() -> void:
	_remember_exploration_bgm_playback_position()
	_switch_to_normal_battle_stream()
	_exploration_bgm_audio_player = null


func play_boss_battle_bgm() -> void:
	_remember_exploration_bgm_playback_position()
	_switch_to_boss_battle_stream()
	_exploration_bgm_audio_player = null


func play_battle_won_bgm() -> void:
	_switch_to_battle_won_stream()
	_exploration_bgm_audio_player = null


func play_game_over_bgm() -> void:
	_switch_to_game_over_stream()
	_exploration_bgm_audio_player = null


func _remember_exploration_bgm_playback_position() -> void:
	if Utils.is_running_on_web():
		# TODO Godot 4.4 (which is still on DEV phase) may fix 
		# get_playback_position() not working on web.
		# See: https://github.com/godotengine/godot/pull/95197 
		return
	
	if _exploration_bgm_audio_player:
		_exploration_bgm_position = \
				_exploration_bgm_audio_player.get_playback_position()


func _switch_to_exploration_stream() -> void:
	var crossfade_duration: float = \
			0.2 if SoundManager.is_music_playing() else 0.0
	_exploration_bgm_audio_player = SoundManager.play_music_from_position(
			BGM_EXPLORATION, _exploration_bgm_position, crossfade_duration)


func _switch_to_normal_battle_stream() -> void:
	SoundManager.play_music(BGM_BATTLE)


func _switch_to_boss_battle_stream() -> void:
	_switch_to_normal_battle_stream()


func _switch_to_battle_won_stream() -> void:
	SoundManager.play_music(BGM_SUCCESS)


func _switch_to_game_over_stream() -> void:
	SoundManager.play_music(BGM_GAME_OVER)
