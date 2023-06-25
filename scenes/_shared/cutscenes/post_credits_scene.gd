extends Node


signal finished

@onready var _animation_player := $BuchoFace/AnimationPlayer as AnimationPlayer


func play() -> void:
	_animation_player.play("default")


func stop() -> void:
	_animation_player.stop()


func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == "default":
		finished.emit()
