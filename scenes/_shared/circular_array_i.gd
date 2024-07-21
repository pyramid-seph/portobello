class_name CircularArrayI
extends RefCounted

var _arr: Array[int]
var _curr_idx: int = -1


func set_array(arr: Array[int]) -> void:
	_arr = arr
	_curr_idx = -1


func is_empty() -> bool:
	return _arr.is_empty()


func next():
	if is_empty():
		return null
	
	_curr_idx = wrapi(_curr_idx + 1, 0, _arr.size())
	return _arr[_curr_idx]
