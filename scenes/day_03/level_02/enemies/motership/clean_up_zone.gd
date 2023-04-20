class_name CleanUpZone
extends Area2D


enum CleanUpBehavior { ON_ENTER, ON_EXIT }

@export var clean_up_behavior := CleanUpBehavior.ON_ENTER
@export var groups: Array[String]


func _is_area_in_group(area: Area2D, group: String) -> bool:
	return area.is_in_group(group)


func _clean_up(area: Area2D) -> void:
	if groups.is_empty():
		area.queue_free()
	else:
		for group in groups:
			if _is_area_in_group(area, group):
				area.queue_free()


func _on_area_entered(area: Area2D) -> void:
	if clean_up_behavior != CleanUpBehavior.ON_ENTER:
		return
	
	_clean_up(area)


func _on_area_exited(area: Area2D) -> void:
	if clean_up_behavior != CleanUpBehavior.ON_EXIT:
		return
	
	_clean_up(area)
