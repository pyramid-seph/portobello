extends CanvasLayer


@export var TitleScreen: PackedScene
@export var _loading_animation_delay_sec: float = 1.0

@onready var _loading_anim_container := $LodingAnimContainer
@onready var _timer := $Timer as Timer


func _ready() -> void:
	visible = false


func load_level(game, mode, level) -> void:
	visible = true
	# TODO Load level
	visible = false


func load_title_screen() -> void:
	visible = true
	get_tree().change_scene_to_packed(TitleScreen)
	visible = false


func _on_timer_timeout() -> void:
	_loading_anim_container.visible = true


func _on_visibility_changed() -> void:
	if visible:
		_timer.start(_loading_animation_delay_sec)
	else:
		_loading_anim_container.visible = false
		_timer.stop()
