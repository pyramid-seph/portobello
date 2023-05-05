extends CanvasLayer


@export var TitleScreen: PackedScene

@onready var _sprite := $AnimatedSprite2D as AnimatedSprite2D


func _ready() -> void:
	visible = false


func load_level(game, mode, level) -> void:
	visible = true
	# TODO


func load_title_screen() -> void:
	visible = true
	get_tree().change_scene_to_packed(TitleScreen)


func _on_visibility_changed() -> void:
	if visible:
		_sprite.play()
	else:
		_sprite.stop()
