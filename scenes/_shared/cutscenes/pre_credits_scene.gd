extends Node


signal finished

@onready var _timer := $Timer as Timer
@onready var _pre_credit_sprite_00 : Sprite2D = $PreCreditsSprite00
@onready var _pre_credits_sprite_01: Sprite2D = $PreCreditsSprite01


func play() -> void:
	_pre_credit_sprite_00.visible = true
	_timer.start(3.0)
	await _timer.timeout
	_pre_credit_sprite_00.visible = false
	_pre_credits_sprite_01.visible = true
	_timer.start(4.0)
	await _timer.timeout
	_pre_credits_sprite_01.visible = false
	finished.emit()


func stop() -> void:
	_timer.stop()
