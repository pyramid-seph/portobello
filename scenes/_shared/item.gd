class_name Item
extends Area2D


signal consumed_or_exited_screen

@export var score_points_pick_up: int
@export var randomize_starting_frame: bool
@export var pick_up_sound: AudioStream

@onready var _is_ready: bool = true
@onready var _animated_sprite := $AnimatedSprite2D as AnimatedSprite2D


func _ready() -> void:
	if randomize_starting_frame:
		_randomize_frame()


func is_ready() -> bool:
	return _is_ready


func get_animated_sprite() -> AnimatedSprite2D:
	return _animated_sprite


func pick_up(picker) -> void:
	_internal_on_pick_up(picker)
	consumed_or_exited_screen.emit()
	queue_free()


# Override
func _on_pick_up(_picker) -> void:
	pass

const SoundEffects = preload("res://addons/sound_manager/sound_effects.gd")
func _internal_on_pick_up(picker) -> void:
	if picker.has_method("add_points_to_score"):
		picker.add_points_to_score(score_points_pick_up)
	if pick_up_sound and not SoundUtils.is_sfx_started_playing(pick_up_sound):
		SoundManager.play_sound(pick_up_sound)
	_on_pick_up(picker)


func _randomize_frame() -> void:
	var frames_count = _animated_sprite.sprite_frames.get_frame_count("default")
	_animated_sprite.frame = randi() % frames_count
	_animated_sprite.play()


func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	consumed_or_exited_screen.emit()
	queue_free()

