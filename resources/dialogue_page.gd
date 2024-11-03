class_name DialoguePage
extends Resource


const MIN_TEXT_SPEED = 0.05

@export var character: String
@export var voice_pack: VoicePack
@export_multiline var line: String
@export var text_speed_chars_per_second: float = 25.0:
	set(value):
		text_speed_chars_per_second = maxf(value, MIN_TEXT_SPEED)
