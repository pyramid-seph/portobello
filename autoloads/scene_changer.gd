extends CanvasLayer

signal change_started
signal change_finished
signal change_error

@export var _min_duration_sec: float = 1.0
@export var _loading_animation_delay_sec: float = 1.0

var _is_busy: bool:
	set(value):
		_is_busy = value
		if _is_busy:
			change_started.emit()
		else:
			change_finished.emit()

@onready var _timer: Timer = $Timer
@onready var _loading_anim_container := $LodingAnimContainer
@onready var _threaded_loader: ThreadedLoader = $ThreadedLoader
@onready var _error_dialog := $ErrorDialog


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	visible = false


func change_to_scene(path: String, shared_data: Dictionary = {}) -> void:
	if _is_busy:
		var msg = """Already changing an scene. Ignoring this request: %s 
				with shared data: %s.""" % [path, shared_data]
		Log.w(msg)
		return
	
	_is_busy = true
	
	var current_scene: Node = Utils.last_child($/root)
	if current_scene:
		current_scene.queue_free()
		while(is_instance_valid(current_scene)):
			await get_tree().process_frame
		current_scene = null
	
	var result: LoadResult = await _load_scene(path)
	if result.is_success():
		var scene: Node = result.get_resource().instantiate()
		if scene.has_method("set_shared_data"):
			scene.set_shared_data(shared_data)
		_is_busy = false
		$/root.add_child(scene)
	else:
		# An error while loading an scene will be considered fatal.
		# I'll just explain the player the situation and
		# give them a way to exit the game.
		change_error.emit()


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


func _on_change_started() -> void:
	visible = true
	_timer.start(_min_duration_sec + _loading_animation_delay_sec)


func _on_change_finished() -> void:
	visible = false
	_loading_anim_container.visible = false
	_timer.stop()


func _on_change_error() -> void:
	_timer.stop()
	_error_dialog.visible = true


class LoadResult:
	extends RefCounted
	
	const SUCCESS: int = 0
	const ERROR: int = 1
	
	var _result: int
	var _resource: Resource
	
	
	func _init(result: int, resource: Resource) -> void:
		_result = result
		_resource = resource
	
	static func error() -> LoadResult:
		return LoadResult.new(ERROR, null)
	
	
	static func success(resource: Resource) -> LoadResult:
		return LoadResult.new(SUCCESS, resource)
	
	
	func get_resource() -> Resource:
		return _resource
	
	
	func is_success() -> bool:
		return _result == SUCCESS
	
	
	func is_error() -> bool:
		return _result == ERROR
