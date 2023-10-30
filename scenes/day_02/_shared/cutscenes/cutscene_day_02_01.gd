extends "res://scenes/_shared/cutscenes/cutscene_2.gd"


@onready var _background := $Background
@onready var _panel_00 := $Background/Panel00
@onready var _timer := $Timer as Timer


func _play() -> void:
	_background.visible = true
	_panel_00.visible = true
	_timer.start(3.6)
	await _timer.timeout
	_panel_00.visible = false
	_timer.start(1.2)
	await _timer.timeout
	finish()


func _clean_up() -> void:
	_timer.stop()
	_background.visible = false
	_panel_00.visible = false


func _on_finished() -> void:
	SceneChanger.change_to_scene(
		"res://scenes/day_02/_shared/game/day_02_game.tscn",
		{ "level": Day02Game.Level.STORY_MODE_LEVEL_01 }
	)
