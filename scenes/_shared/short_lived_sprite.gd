extends Sprite2D

@export var sound_effect: AudioStream


func _ready() -> void:
	if sound_effect and not SoundUtils.is_sfx_started_playing(sound_effect):
		var pitch: float = randf_range(0.8, 1.2)
		SoundManager.play_sound_with_pitch(sound_effect, pitch)


func _on_Timer_timeout():
	queue_free()
