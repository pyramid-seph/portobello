extends "res://scenes/_shared/cutscenes/cutscene.gd"


@onready var _timer := $Timer as Timer
@onready var _background := $Background
@onready var _panel_00 := $Panel00
@onready var _panel_01 := $Panel01
@onready var _panel_02 := $Panel02


func _play() -> void:
	_background.visible = true
	_panel_00.visible = true
	_timer.start(4.0)
	await _timer.timeout
	_panel_00.visible = false
	_panel_01.visible = true
	_timer.start(1.0)
	await _timer.timeout
	_panel_01.visible = false
	_panel_02.visible = true
	_timer.start(4.0)
	await _timer.timeout
	finish()


func _clean_up() -> void:
	_timer.stop()
	_background.visible = false
	_panel_00.visible = false
	_panel_01.visible = false
	_panel_02.visible = false


func _on_finished() -> void:
	Game.start(Game.Minigame.TITLE_SCREEN)
