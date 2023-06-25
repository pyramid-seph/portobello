class_name CleanUpZone
extends Area2D


enum CleanUpBehavior { ON_ENTER, ON_EXIT }

@export var clean_up_behavior := CleanUpBehavior.ON_ENTER
@export var groups: Array[String]


func _is_node_in_group(node: Node, group: String) -> bool:
	return node.is_in_group(group)


func _clen_up_group(node: Node) -> void:
	for group in groups:
		if _is_node_in_group(node, group):
			node.queue_free()


func _clean_up(area: Area2D) -> void:
	if groups.is_empty():
		if area.owner:
			area.owner.queue_free()
		else:
			area.queue_free()
	elif area.owner:
		_clen_up_group(area.owner)
	else:
		_clen_up_group(area)

func _on_area_entered(area: Area2D) -> void:
	if clean_up_behavior != CleanUpBehavior.ON_ENTER:
		return
	
	_clean_up(area)


func _on_area_exited(area: Area2D) -> void:
	if clean_up_behavior != CleanUpBehavior.ON_EXIT:
		return
	
	_clean_up(area)
