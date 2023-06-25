extends Node


signal finished

@onready var _timer := $Timer as Timer
@onready var _pre_credit_sprite := $PreCreditsSprite


func play() -> void:
	_pre_credit_sprite.visible = true
	_timer.start()


func stop() -> void:
	_timer.stop()


func _on_timer_timeout() -> void:
	_pre_credit_sprite.visible = false
	finished.emit()
