extends CanvasLayer

@onready var _animation_player: AnimationPlayer = $AnimationPlayer


func play_default() -> void:
	_animation_player.play("default")
	await _animation_player.animation_finished


func play_default_backwards() -> void:
	_animation_player.play_backwards("default")
	await _animation_player.animation_finished


func play_battle() -> void:
	_animation_player.play("battle")
	await _animation_player.animation_finished


func play_battle_backwards() -> void:
	_animation_player.play_backwards("battle")
	await _animation_player.animation_finished


func reset() -> void:
	_animation_player.play("RESET")
	await _animation_player.animation_finished
