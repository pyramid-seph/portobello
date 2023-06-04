extends CanvasLayer

signal scene_change_started
signal scene_change_finished
signal scene_change_error

@export var _min_duration_sec: float = 1.0
@export var _loading_animation_delay_sec: float = 1.0

var _changing_scene: bool:
	set(value):
		_changing_scene = value
		if _changing_scene:
			scene_change_started.emit()
		else:
			scene_change_finished.emit()

@onready var _timer := $Timer as Timer
@onready var _loading_anim_container := $LodingAnimContainer
@onready var _threaded_loader := $ThreadedLoader as ThreadedLoader
@onready var _error_dialog := $ErrorDialog


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	visible = false


func change_to_scene(
		path: String,
		shared_data: Dictionary = {},
		scene_to_replace: Node = Utils.last_child($/root)
) -> void:
	if _changing_scene:
		var msg = """Already changing the scene. Ignoring this request: %s 
				with shared data: %s.""" % [path, shared_data]
		print(msg)
		return
	
	_changing_scene = true
	var scene_parent = null
	if scene_to_replace:
		scene_parent = scene_to_replace.get_parent()
		scene_to_replace.queue_free()
		await get_tree().process_frame
	
	if scene_parent == null:
		scene_parent = $/root
	
	var result = await _load_scene(path)
	if result.is_success():
		var scene = result.get_resource().instantiate()
		if scene.has_method("set_shared_data"):
			scene.set_shared_data(shared_data)
		_changing_scene = false
		scene_parent.add_child(scene)
	else:
		# An error while changing scenes will be considered fatal.
		# We'll just tell the player the situation and... that's it.
		scene_change_error.emit()


func _load_scene(path: String) -> LoadResult:
	var request: ThreadedLoader.Request = _threaded_loader.make_request(path)
	
	if request.is_error():
		return LoadResult.error()
	
	await get_tree().create_timer(_min_duration_sec).timeout
	if request.is_in_progress():
		await request.finished
	
	if request.is_loaded():
		return LoadResult.success(request.loaded_resource)
	else:
		return LoadResult.error()


func _on_timer_timeout() -> void:
	_loading_anim_container.visible = true


func _on_simple_dialog_positive_btn_pressed() -> void:
	get_tree().quit(1)


func _on_scene_change_started() -> void:
	visible = true
	_timer.start(_min_duration_sec + _loading_animation_delay_sec)
	get_tree().paused = true


func _on_scene_change_finished() -> void:
	visible = false
	_loading_anim_container.visible = false
	_timer.stop()
	get_tree().paused = false


func _on_scene_change_error() -> void:
	_timer.stop()
	_error_dialog.visible = true


class LoadResult:
	extends RefCounted
	
	const SUCCESS = 0
	const ERROR = 1
	
	var _result: int
	var _resource: Resource
	
	
	func _init(result: int, resource: Resource) -> void:
		_result = result
		_resource = resource
	
	static func  error() -> LoadResult:
		return LoadResult.new(ERROR, null)
	
	
	static func  success(resource: Resource) -> LoadResult:
		return LoadResult.new(SUCCESS, resource)
	
	
	func get_resource() -> Resource:
		return _resource
	
	
	func is_success() -> bool:
		return _result == SUCCESS
	
	
	func is_error() -> bool:
		return _result == ERROR
