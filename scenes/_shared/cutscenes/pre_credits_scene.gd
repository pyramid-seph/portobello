extends Node


signal finished

const BGM_CUTSCENE_LOOP = preload("res://audio/bgm/cutscene_loop.wav")

@onready var _timer := $Timer as Timer
@onready var _pre_credit_sprite_00 : Sprite2D = $PreCreditsSprite00
@onready var _pre_credits_sprite_01: Sprite2D = $PreCreditsSprite01


func play() -> void:
	SoundManager.play_music(BGM_CUTSCENE_LOOP)
	_pre_credit_sprite_00.show()
	_timer.start(3.0)
	await _timer.timeout
	_pre_credit_sprite_00.hide()
	_pre_credits_sprite_01.show()
	_timer.start(4.0)
	await _timer.timeout
	_pre_credits_sprite_01.hide()
	SoundManager.stop_music(1.5)
	_timer.start(1.5)
	await _timer.timeout
	finished.emit()


func stop() -> void:
	SoundManager.stop_music()
	_timer.stop()
