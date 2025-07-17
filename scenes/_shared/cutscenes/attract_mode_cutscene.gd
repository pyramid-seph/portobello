extends "res://scenes/_shared/cutscenes/cutscene.gd"


@onready var _animation_player: AnimationPlayer = $AnimationPlayer
@onready var _panel_container: PanelContainer = $PanelContainer
@onready var _bgm: SimpleBgmPlayer = $SimpleBgmPlayer


func _play() -> void:
	_animation_player.play(&"cutscene")
	_animation_player.advance(0)


func _clean_up() -> void:
	_bgm.stop()
	_animation_player.stop()
	_panel_container.hide()


func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == &"cutscene":
		finish()
