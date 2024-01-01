extends Sprite2D

@export var sound_effect: AudioStream


func _ready() -> void:
	if sound_effect:
		SoundManager.play_sound(sound_effect)


func _on_Timer_timeout():
	queue_free()
