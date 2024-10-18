class_name SimpleBgmPlayer
extends Node

@export var _music: AudioStream
@export var _autostart: bool = true


func _ready() -> void:
	if _autostart:
		play()


func _exit_tree() -> void:
	stop()


func play(position: float = 0.0) -> void:
	if _music:
		SoundManager.play_music_from_position(_music, position)


func stop() -> void:
	SoundManager.stop_music()
