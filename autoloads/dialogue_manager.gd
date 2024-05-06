extends Node

signal scene_play_requested(scene: Array[DialoguePage])

func play_scene(scene: Array[DialoguePage]) -> void:
	if scene_play_requested.get_connections().is_empty():
		print("No dialogue box connected to scene_play_requested. Skipping this dialogue scene.")
	else:
		scene_play_requested.emit(scene)
