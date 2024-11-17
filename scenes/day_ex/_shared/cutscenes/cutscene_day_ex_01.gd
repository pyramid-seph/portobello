extends "res://scenes/_shared/cutscenes/cutscene.gd"


const BGM_CUTSCENE = preload("res://audio/bgm/cutscene.wav")
const BGM_CUTSCENE_ENDS = preload("res://audio/bgm/cutscene_ends.wav")

@onready var _timer: Timer = $Timer
@onready var _day_label: Label = $ColorRect/DayLabel
@onready var _background: ColorRect = $ColorRect


func _play() -> void:
	_background.show()
	_timer.start(0.2)
	await _timer.timeout
	_day_label.show()
	await SoundManager.play_music(BGM_CUTSCENE_ENDS).finished
	finish()


func _clean_up() -> void:
	if not _timer.is_stopped():
		_timer.stop()
		Utils.safe_disconnect_all(_timer.timeout)
	_background.hide()
	_day_label.hide()


func _on_finished() -> void:
	SceneChanger.change_to_scene("res://scenes/day_ex/game/day_ex_game.tscn")
