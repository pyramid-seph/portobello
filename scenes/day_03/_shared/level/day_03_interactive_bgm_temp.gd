class_name Day03InteractiveBgmTemp
extends Node


const NORMAL_STAMINA_PITCH: float = 1.0


func _exit_tree() -> void:
	stop_music()


func play_music() -> void:
	pass # NOOP


func stop_music(fade_out_duration_sec: float = 0.0) -> void:
	SoundManager.stop_music(fade_out_duration_sec)

