extends "res://scenes/_shared/cutscenes/cutscene.gd"


const _DELAY_SEC_DAY_TITLE: float = 1.0
const _DURATION_SEC_DAY_TITLE: float = 1.2

@onready var _timer: Timer = $Timer
@onready var _day_label: Label = $ColorRect/DayLabel


func _play() -> void:
	_timer.start(_DELAY_SEC_DAY_TITLE)
	await _timer.timeout
	_day_label.show()
	_timer.start(_DURATION_SEC_DAY_TITLE)
	await _timer.timeout
	finish()


func _on_finished() -> void:
	SceneChanger.change_to_scene("res://scenes/day_ex/game/day_ex_game.tscn")
