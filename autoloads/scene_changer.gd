extends CanvasLayer


@export var TitleScreen: PackedScene


func _ready() -> void:
	visible = false


func load_level(game, mode, level) -> void:
	visible = true
	# TODO


func load_title_screen() -> void:
	visible = true
	get_tree().change_scene_to_packed(TitleScreen)
