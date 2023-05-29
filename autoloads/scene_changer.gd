extends CanvasLayer

@export var _min_duration_sec: float = 1.0
@export var _loading_animation_delay_sec: float = 1.0

var _request: ThreadedLoader.Request

@onready var _timer := $Timer as Timer
@onready var _loading_anim_container := $LodingAnimContainer
@onready var _threaded_loader := $ThreadedLoader as ThreadedLoader


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	visible = false


func load_resource(path: String) -> Resource:
	if _request:
		print("Already changing the scene. Ignoring.")
		return null
	
	visible = true
	var current_scene := Utils.last(get_node("/root").get_children()) as Node
	if current_scene:
		current_scene.queue_free()
		await get_tree().process_frame
		current_scene = null
	
	_request = _threaded_loader.request(path)
	
	if _request.status == ThreadedLoader.Request.Status.ERROR:
		visible = false
		_request = null
		# TODO What should we show in case of error?
		return null
	
	await get_tree().create_timer(_min_duration_sec).timeout
	if _request.status == ThreadedLoader.Request.Status.IN_PROGRESS:
		await _request.finished
	
	visible = false
	
	var resource = null
	if _request.status == ThreadedLoader.Request.Status.LOADED:
		resource = _request.loaded_resource
	_request = null
	return resource


func change_to_scene(path: String, shared_data: Dictionary = {}) -> void:
	# TODO maybe  i should move this to Game?
	var resource = await load_resource(path)
	if resource:
		var scene = resource.instantiate()
		if scene.has_method("set_shared_data"):
			scene.set_shared_data(shared_data)
		get_node("/root").add_child(scene)


func _on_timer_timeout() -> void:
	_loading_anim_container.visible = true


func _on_visibility_changed() -> void:
	if visible:
		_timer.start(_min_duration_sec + _loading_animation_delay_sec)
	else:
		_loading_anim_container.visible = false
		_timer.stop()
