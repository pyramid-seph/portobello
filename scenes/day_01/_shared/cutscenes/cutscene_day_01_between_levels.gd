extends "res://scenes/_shared/cutscenes/cutscene.gd"

const ANIM_DEFAULT: String = "Default"
const ANIM_DIZZY: String = "Dizzy"

@export var inverted_controls: bool

@onready var _animator := $AnimationPlayer as AnimationPlayer
@onready var _color_rect := $ColorRect
# TODO cutscene mode while playing

func _ready() -> void:
	super()
	_color_rect.visible = false


func _play() -> void:
	var animation_name = ANIM_DIZZY if inverted_controls else ANIM_DEFAULT
	_animator.play(animation_name)


func _clean_up() -> void:
	if _animator.is_playing():
		_animator.stop()
	_color_rect.visible = false


func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == ANIM_DEFAULT or anim_name == ANIM_DIZZY:
		finish()
