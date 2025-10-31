extends Node


const HIDE_DELAY_SECS: float = 1.0

var _hide_delay_timer: float
var _past_mouse_pos: Vector2


func _init() -> void:
	process_mode = PROCESS_MODE_ALWAYS


func _ready() -> void:
	set_process(false)
	
	var viewport: Viewport = get_viewport()
	var window: Window = viewport.get_window()
	window.mouse_entered.connect(_on_mouse_entered)
	window.mouse_exited.connect(_on_mouse_exited)
	
	if not Engine.is_embedded_in_editor():
		viewport.warp_mouse(viewport.get_visible_rect().size / 2.0)
		viewport.update_mouse_cursor_state()


func _process(delta: float) -> void:
	_hide_delay_timer += delta
	
	if Engine.get_process_frames() % 5 != 0:
		return
	
	var curr_mouse_pos: Vector2 = get_viewport().get_mouse_position()
	var mouse_moved: bool = not curr_mouse_pos.is_equal_approx(_past_mouse_pos)
	if mouse_moved:
		if Input.mouse_mode == Input.MOUSE_MODE_HIDDEN:
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
			_hide_delay_timer = 0.0
	elif Input.mouse_mode == Input.MOUSE_MODE_VISIBLE:
		if _hide_delay_timer > HIDE_DELAY_SECS:
			Input.mouse_mode = Input.MOUSE_MODE_HIDDEN
	
	_past_mouse_pos = curr_mouse_pos


func _on_mouse_entered() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	set_process(true)
	_hide_delay_timer = 0.0
	_past_mouse_pos = get_viewport().get_mouse_position()


func _on_mouse_exited() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	set_process(false)
