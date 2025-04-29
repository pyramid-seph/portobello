extends Node


signal finished

const BGM_CUTSCENE = preload("res://audio/bgm/cutscene.wav")

@onready var _timer := $Timer as Timer
@onready var _pre_credit_sprite_00 : Sprite2D = $PreCreditsSprite00
@onready var _pre_credits_sprite_01: Sprite2D = $PreCreditsSprite01


func play() -> void:
	_pre_credit_sprite_00.show()
	await SoundManager.play_music(BGM_CUTSCENE).finished
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
