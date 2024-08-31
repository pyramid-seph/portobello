class_name SpeakActionArea
extends ActionArea


@export var _dialogue: Array[DialoguePage]


func _is_executable() -> bool:
	return false


func _execute(target: CharacterBody2D) -> void:
	if target:
		DialogueManager.play_scene(_dialogue)
	# TODO enable after the scene is played
