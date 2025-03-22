extends Node


const Ghost = preload("res://scenes/day_02/_shared/enemies/day_02_enemy.gd")
const BGM = preload("res://audio/bgm/remaki_0.wav")


func _exit_tree() -> void:
	if not Engine.is_editor_hint():
		stop()


func play() -> void:
	SoundManager.play_music(BGM)


func stop() -> void:
	if _is_playing():
		SoundManager.stop_music()


func _is_playing() -> bool:
	return SoundManager.is_music_playing(BGM)
