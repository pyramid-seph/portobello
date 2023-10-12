extends "res://scenes/_shared/cutscenes/cutscene_2.gd"


@onready var _pre_credits_scene := $PreCreditsScene
@onready var _end_credits := $EndCredits
@onready var _post_credits_scene := $PostCreditsScene
@onready var _timer := $Timer as Timer


func _play() -> void:
	_timer.start(2.0)
	await _timer.timeout
	_pre_credits_scene.play()
	await _pre_credits_scene.finished
	_timer.start(1.2)
	await _timer.timeout
	_end_credits.play()
	await _end_credits.finished
	_post_credits_scene.play()
	await _post_credits_scene.finished
	finish()


func _clean_up() -> void:
	_timer.stop()
	_pre_credits_scene.stop()
	_end_credits.stop()
	_post_credits_scene.stop()


func _on_finished() -> void:
	Game.start(Game.Minigame.TITLE_SCREEN)
