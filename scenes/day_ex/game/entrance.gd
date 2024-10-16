@tool
extends Node2D

signal color_tag_changed


const Player = preload("res://scenes/day_ex/player/day_ex_player.gd")

## Direction the player will face when they are teletransported to this entrance.
@export var initial_direction: Player.FacingDirection
## Minimum time in seconds a player should walk before triggering a battle event.
@export var min_time_before_battles_sec: float = 1.0
@export_color_no_alpha var color_tag: Color = Color.WHITE:
	set(value):
		color_tag = value
		if is_node_ready():
			_sprite_2d.self_modulate = color_tag
			color_tag_changed.emit()
@export var _camera_pos: CameraPos:
	set(value):
		_camera_pos = value
		update_configuration_warnings()

@onready var _sprite_2d: Sprite2D = $Sprite2D
@onready var _timer: Timer = $Timer


func _ready() -> void:
	_sprite_2d.visible = Engine.is_editor_hint()
	_sprite_2d.self_modulate = color_tag


func _get_configuration_warnings() -> PackedStringArray:
	var warnings: PackedStringArray = []
	if not _camera_pos:
		warnings.append("A CameraPos reference is required.")
	return warnings


func teleport_here(player: Player, distance_offset: Vector2 = Vector2.ZERO) -> void:
	if not player:
		return
	
	if not _camera_pos:
		print("A CameraPos reference is required. The player won't be repositioned.")
		return
	
	player.set_process_unhandled_input(false)
	await TransitionPlayer.play_default()
	player.teleport(global_position + distance_offset, initial_direction)
	var camera: Camera2D = get_viewport().get_camera_2d()
	if camera:
		camera.global_position = _camera_pos.global_position
	_timer.start(1.0)
	await _timer.timeout
	await TransitionPlayer.play_default_backwards()
	player.set_process_unhandled_input(true)
