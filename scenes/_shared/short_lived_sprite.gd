extends Sprite2D

@export var sound_effect: AudioStream


func _ready() -> void:
	var is_sfx_playing: bool = SoundUtils.is_sfx_started_playing(sound_effect)
	print("is_sfx_started_playing: ", is_sfx_playing)
	if sound_effect and not is_sfx_playing:
		SoundManager.play_sound(sound_effect)


func _on_Timer_timeout():
	queue_free()
