extends "res://scenes/_shared/cutscenes/cutscene.gd"


const BGM_CUTSCENE = preload("res://audio/bgm/cutscene.mp3")
const BGM_CUTSCENE_ENDS = preload("res://audio/bgm/cutscene_ends.mp3")

@onready var _day_label := $ColorRect/DayLabel
@onready var _image_sprite := $ColorRect/Sprite2D
@onready var _timer: Timer = $Timer


func _play() -> void:
	_image_sprite.show()
	await SoundManager.play_music(BGM_CUTSCENE).finished
	_image_sprite.hide()
	SoundManager.stop_music(1.5)
	_timer.start(2.0)
	await _timer.timeout
	_day_label.show()
	await SoundManager.play_music(BGM_CUTSCENE_ENDS).finished
	finish()


func _clean_up() -> void:
	if not _timer.is_stopped():
		_timer.stop()
		Utils.safe_disconnect_all(_timer.timeout)
	_image_sprite.hide()
	_day_label.hide()


func _on_finished() -> void:
	SceneChanger.change_to_scene("res://scenes/day_03/_shared/game/day_03_game.tscn")
