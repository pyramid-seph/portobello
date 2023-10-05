extends "res://scenes/_shared/cutscenes/cutscene_2.gd"

@onready var _background := $Background
@onready var _panel_00 := $Panel00
@onready var _panel_01 := $Panel01
@onready var _timer := $Timer as Timer


func _play() -> void:
	_background.visible = true
	_panel_00.visible = true
	_timer.start(2.0)
	await _timer.timeout
	_panel_00.visible = false
	_panel_01.visible = true
	_timer.start(1.6)
	await _timer.timeout
	_panel_00.visible = false
	_panel_01.visible = false
	_timer.start(1.2)
	await _timer.timeout
	finish()


func _clean_up() -> void:
	_timer.stop()
	_background.visible = false
	_panel_00.visible = false
	_panel_01.visible = true


func _on_finished() -> void:
	SceneChanger.change_to_scene(
		"res://scenes/day_01/_shared/game/day_01_game.tscn",
		{ "level": Day01Game.Level.STORY_MODE_LEVEL_01 }
	)
