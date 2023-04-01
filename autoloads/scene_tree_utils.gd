extends Node

func rand_item_in_group(group: String) -> Node:
	return Utils.rand_item(get_tree().get_nodes_in_group(group))


func get_item_count_in_group(group: String) -> int:
	return get_tree().get_nodes_in_group(group).size()
