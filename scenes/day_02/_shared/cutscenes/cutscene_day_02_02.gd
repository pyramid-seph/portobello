extends "res://scenes/_shared/cutscenes/cutscene.gd"

const BGM_CUTSCENE_LOOP = preload("res://audio/bgm/cutscene_loop.wav")

@onready var _timer := $Timer as Timer
@onready var _background := $Background
@onready var _panel_00 := $Panel00
@onready var _panel_01 := $Panel01
@onready var _panel_02 := $Panel02


func _play() -> void:
	SoundManager.play_music(BGM_CUTSCENE_LOOP)
	_background.show()
	_panel_00.show()
	_timer.start(4.0)
	await _timer.timeout
	_panel_00.hide()
	SoundManager.stop_music(2.0)
	_timer.start(2.0)
	await _timer.timeout
	_panel_01.show()
	_timer.start(1.0)
	await _timer.timeout
	_panel_01.hide()
	_panel_02.show()
	_timer.start(4.0)
	await _timer.timeout
	finish()


func _clean_up() -> void:
	if not _timer.is_stopped():
		_timer.stop()
		Utils.safe_disconnect_all(_timer.timeout)
	_background.hide()
	_panel_00.hide()
	_panel_01.hide()
	_panel_02.hide()


func _on_finished() -> void:
	Game.start(Game.Minigame.TITLE_SCREEN)
