class_name ThreadedLoader
extends Node

var _queue: Dictionary[String, Request]
var _progress: Array[float]


func _ready() -> void:
	set_process(false)


func _process(_delta: float) -> void:
	var removed: Array[String] = []
	for path: String in _queue:
		var request: Request = _queue[path]
		var status: ResourceLoader.ThreadLoadStatus = \
				ResourceLoader.load_threaded_get_status(path, _progress)
		request.progress = _progress[0]
		match status:
			ResourceLoader.THREAD_LOAD_IN_PROGRESS:
				request.progressed.emit()
				continue
			ResourceLoader.THREAD_LOAD_LOADED:
				removed.append(path)
				request.loaded_resource = ResourceLoader.load_threaded_get(path)
				request.status = Request.Status.LOADED
				request.finished.emit()
			_:
				removed.append(path)
				request.status = Request.Status.ERROR
				request.finished.emit()
	for path: String in removed:
		_queue.erase(path)
	if _queue.is_empty():
		set_process(false)


func make_request(path: String, use_sub_threads: bool = false) -> Request:
	if _queue.has(path):
		return _queue[path]
	
	var error: Error = ResourceLoader.load_threaded_request(path, "",
			use_sub_threads)
	var request: Request = Request.new()
	_queue[path] = request
	if error:
		request.status = Request.Status.ERROR
	else:
		set_process(true)
	return request


class Request:
	extends RefCounted

	signal progressed
	signal finished

	enum Status {
		IN_PROGRESS,
		LOADED,
		ERROR,
	}
 
	var loaded_resource: Resource
	var status: Request.Status = Status.IN_PROGRESS
	var progress: float
	
	func is_in_progress() -> bool:
		return status == Status.IN_PROGRESS
	
	
	func is_loaded() -> bool:
		return status == Status.LOADED
	
	
	func is_error() -> bool:
		return status == Status.ERROR
