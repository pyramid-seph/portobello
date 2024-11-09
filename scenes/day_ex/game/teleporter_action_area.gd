@tool
extends ActionArea


const Player = preload("res://scenes/day_ex/player/day_ex_player.gd")

@export var initial_direction: Player.FacingDirection
@export var _exit: Marker2D:
	set(value):
		_exit = value
		update_configuration_warnings()
@export var sound: AudioStream

var _is_teleporting: bool

@onready var _timer: Timer = $Timer


func _get_configuration_warnings() -> PackedStringArray:
	var warnings: Array[String] = []
	if not _exit:
		warnings.append("This teleporter has no exit.")
	return warnings


func _is_executable() -> bool:
	return not _is_teleporting


func _execute(target: CharacterBody2D) -> void:
	var player := target as Player
	if player and _exit and not _is_teleporting:
		_is_teleporting = true
		player.set_process_unhandled_input(false)
		await TransitionPlayer.play_default()
		if sound:
			SoundManager.play_sound(sound)
		var offset: Vector2 = player.global_position - global_position
		player.teleport(_exit.global_position + offset, initial_direction)
		_timer.start(1.0)
		await _timer.timeout
		await TransitionPlayer.play_default_backwards()
		player.set_process_unhandled_input(true)
		_is_teleporting = false
