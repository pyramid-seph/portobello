extends "res://scenes/_shared/cutscenes/cutscene.gd"

const BGM_CUTSCENE = preload("res://audio/bgm/cutscene.wav")
const BGM_CUTSCENE_ENDS = preload("res://audio/bgm/cutscene_ends.mp3")

@onready var _background := $Background
@onready var _panel_00 := $Panel00
@onready var _panel_01 := $Panel01
@onready var _timer := $Timer as Timer
@onready var _title_label: Label = $Background/Label


func _play() -> void:
	_background.show()
	_panel_00.show()
	await SoundManager.play_music(BGM_CUTSCENE).finished
	_panel_00.hide()
	_panel_01.show()
	await SoundManager.play_music(BGM_CUTSCENE).finished
	_panel_00.hide()
	_panel_01.hide()
	SoundManager.stop_music(1.5)
	_timer.start(2.0)
	await _timer.timeout
	_title_label.show()
	await SoundManager.play_music(BGM_CUTSCENE_ENDS).finished
	finish()


func _clean_up() -> void:
	# Awaiting for a signal to be fired creates one shot connections.
	# Do not disconnect one shot callables if the timer is stopped
	# or else an "attempt to disconnect a nonexistent connection"
	# error will be raised.
	if not _timer.is_stopped():
		_timer.stop()
		Utils.safe_disconnect_all(_timer.timeout)
	_background.hide()
	_panel_00.hide()
	_panel_01.hide()
	_title_label.hide()


func _on_finished() -> void:
	SceneChanger.change_to_scene(
		"res://scenes/day_01/_shared/game/day_01_game.tscn",
		{ "level": Day01Game.Level.STORY_MODE_LEVEL_01 }
	)
