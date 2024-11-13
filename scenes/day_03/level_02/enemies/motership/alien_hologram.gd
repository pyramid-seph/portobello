extends Sprite2D

const SFX_ALIEN_HOLOGRAM_VISIBLE = preload("res://audio/sfx/sfx_motership_hologram.wav")

@export var _flicker_duration_sec: float = 1.0

var _tween: Tween


func _exit_tree() -> void:
	SoundManager.stop_sound(SFX_ALIEN_HOLOGRAM_VISIBLE)


func _stop_animation() -> void:
	SoundManager.stop_sound(SFX_ALIEN_HOLOGRAM_VISIBLE)
	if _tween:
		_tween.kill()
		_tween = null


func _animate() -> void:
	_stop_animation()
	SoundManager.play_sound(SFX_ALIEN_HOLOGRAM_VISIBLE)
	_tween = create_tween()
	_tween.set_loops()
	_tween.tween_callback(set_modulate.bind(Color.TRANSPARENT))
	_tween.tween_interval(_flicker_duration_sec)
	_tween.tween_callback(set_modulate.bind(Color.WHITE))
	_tween.tween_interval(_flicker_duration_sec)


func _on_visibility_changed() -> void:
	if visible:
		_animate()
	else:
		_stop_animation()
