class_name SpeakActionArea
extends ActionArea


@export var _dialogue: Array[DialoguePage]


func execute(target: CharacterBody2D) -> void:
	if target:
		DialogueManager.play_scene(_dialogue)
