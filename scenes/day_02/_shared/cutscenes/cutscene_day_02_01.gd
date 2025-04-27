extends "res://scenes/_shared/cutscenes/cutscene.gd"

const BGM_CUTSCENE = preload("res://audio/bgm/cutscene.wav")
const BGM_CUTSCENE_ENDS = preload("res://audio/bgm/cutscene_ends.mp3")

@onready var _background := $Background
@onready var _panel_00 := $Background/Panel00
@onready var _timer := $Timer as Timer
@onready var _label: Label = $Background/Label


func _play() -> void:
	_background.show()
	_panel_00.show()
	await SoundManager.play_music(BGM_CUTSCENE).finished
	_panel_00.hide()
	SoundManager.stop_music(1.5)
	_timer.start(2.0)
	await _timer.timeout
	_label.show()
	await SoundManager.play_music(BGM_CUTSCENE_ENDS).finished
	finish()


func _clean_up() -> void:
	if not _timer.is_stopped():
		_timer.stop()
		Utils.safe_disconnect_all(_timer.timeout)
	_background.hide()
	_panel_00.hide()
	_label.hide()


func _on_finished() -> void:
	SceneChanger.change_to_scene(
		"res://scenes/day_02/_shared/game/day_02_game.tscn",
		{ "level": Day02Game.Level.STORY_MODE_LEVEL_01 }
	)
