extends "res://scenes/_shared/cutscenes/cutscene.gd"

const _DURATION_SEC_IMAGE: float = 3.6
const _DURATION_SEC_DAY_TITLE: float = 1.2

var _tween: Tween

@onready var _day_label = $Control/DayLabel
@onready var _image_sprite = $Sprite2D


func _play() -> void:
	if _tween:
		_tween.kill()
	_tween = create_tween()
	_day_label.visible = false
	_image_sprite.visible = true
	_tween.tween_interval(_DURATION_SEC_IMAGE)
	_tween.tween_callback(func(): 
		_day_label.visible = true
		_image_sprite.visible = false
	)
	_tween.tween_interval(_DURATION_SEC_DAY_TITLE)
	_tween.finished.connect(func():
		_day_label.visible = false
		finish()
	)


func _clean_up() -> void:
	if _tween and _tween.is_running():
		_tween.kill()


func _on_finished() -> void:
	SceneChanger.change_to_scene("res://scenes/day_03/_shared/game/day_03_game.tscn")
