class_name DialogueEvent
extends Resource


@warning_ignore("unused_signal")
signal finished

@export var _dialogue: Array[DialoguePage]


func is_empty() -> bool:
	return not _dialogue or _dialogue.is_empty()


func get_page(idx: int) -> DialoguePage:
	if is_empty() or idx < 0 or idx >= _dialogue.size():
		return null
	
	return _dialogue[idx]


func get_page_count() -> int:
	return 0 if is_empty() else _dialogue.size()
