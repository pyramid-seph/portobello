extends Node


signal play_requested(dialogue_event: DialogueEvent)


func play(dialogue_event: DialogueEvent) -> void:
	if play_requested.get_connections().is_empty():
		print("No dialogue box connected. Dialogue event will finish.")
		# Awaiting a process frame so callers of play() don't miss 
		# the finished signal when they connect to it right after playing 
		# when no dialogue box is registered.
		await get_tree().process_frame
		dialogue_event.finished.emit()
	else:
		play_requested.emit(dialogue_event)
