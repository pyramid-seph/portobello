extends Node


const HIDE_DELAY_SECS: float = 1.0

var _hide_delay_timer: float
var _past_mouse_pos: Vector2


func _ready() -> void:
	process_mode = PROCESS_MODE_ALWAYS
	set_process(_is_mouse_inside_viewport())


func _notification(what: int) -> void:
	if not is_node_ready():
		return
	
	match what:
		NOTIFICATION_WM_MOUSE_ENTER:
			set_process(true)
			_hide_delay_timer = 0.0
			_past_mouse_pos = Vector2.ZERO
		NOTIFICATION_WM_MOUSE_EXIT:
			set_process(false)


func _process(delta: float) -> void:
	var curr_mouse_pos: Vector2 = get_viewport().get_mouse_position()
	var mouse_moved: bool = not curr_mouse_pos.is_equal_approx(_past_mouse_pos)
	if mouse_moved:
		if Input.mouse_mode == Input.MOUSE_MODE_HIDDEN:
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
			_hide_delay_timer = 0.0
	elif Input.mouse_mode == Input.MOUSE_MODE_VISIBLE:
		_hide_delay_timer += delta
		if _hide_delay_timer > HIDE_DELAY_SECS:
			Input.mouse_mode = Input.MOUSE_MODE_HIDDEN
	
	_past_mouse_pos = curr_mouse_pos


func _is_mouse_inside_viewport() -> bool:
	var viewport: Viewport = get_viewport()
	var mouse_pos: Vector2 = viewport.get_mouse_position()
	return viewport.get_visible_rect().has_point(mouse_pos)
