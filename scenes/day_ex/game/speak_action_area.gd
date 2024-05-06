extends Area2D


@export var _dialogue: Array[DialoguePage]


func execute(target: CharacterBody2D) -> void:
	if target:
		DialogueManager.play_scene(_dialogue)
