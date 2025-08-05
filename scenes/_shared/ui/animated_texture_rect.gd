@tool
extends TextureRect


@export var frames: Array[Texture2D]:
	set(value):
		frames = value
		_on_frames_set()
@export var frame_duration_sec: float = 1.0:
	set(value):
		frame_duration_sec = value
		_on_frame_duration_sec_set()
@export var _autostart: bool = true
@export var preview: bool:
	set(value):
		preview = value
		_on_preview_set()

var _tween: Tween
var _is_playing: bool


func _ready() -> void:
	_on_frames_set()
	_on_frame_duration_sec_set()
	# _on_preview_set is called by previous methods
	
	if _autostart and not Engine.is_editor_hint():
		play()


func play() -> void:
	stop()
	
	if frames.is_empty():
		return
	
	_is_playing = true
	_tween = create_tween()
	_tween.set_loops()
	for frame in frames:
		_tween.tween_callback(set_texture.bind(frame))
		_tween.tween_interval(frame_duration_sec)


func stop() -> void:
	_is_playing = false
	if _tween:
		_tween.kill()
	_tween = null
	_set_default_texture()


func is_playing() -> bool:
	return _is_playing


func _set_default_texture() -> void:
	if frames.is_empty():
		texture = null
	else:
		texture = frames[0]


func _on_frames_set() -> void:
	if not is_node_ready():
		return
	_set_default_texture()
	_on_preview_set()


func _on_frame_duration_sec_set() -> void:
	if not is_node_ready():
		return
	_on_preview_set()


func _on_preview_set() -> void:
	if not is_node_ready():
		return
	if preview:
		play()
	else:
		stop()
