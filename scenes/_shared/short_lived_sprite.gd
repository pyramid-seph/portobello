extends Sprite2D

@export var sound_effect: Array[AudioStream]


func _ready() -> void:
	if sound_effect.is_empty():
		return
	
	var sound: AudioStream = sound_effect.pick_random()
	if not SoundUtils.is_sfx_started_playing(sound):
		SoundManager.play_sound(sound)


func _on_Timer_timeout():
	queue_free()
