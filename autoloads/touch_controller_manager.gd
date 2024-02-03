extends Node

const TouchScreenControllerScn = preload("res://scenes/_shared/touch_controller/touch_screen_controller.tscn")
const TouchScreenController = preload("res://scenes/_shared/touch_controller/touch_screen_controller.gd")

const _button_action_main_accept_texture = preload("res://art/_shared/touch_button_action_main_accept.png")
const _button_action_main_fire_texture = preload("res://art/_shared/touch_button_action_main_fire.png")
const _button_action_main_skip_texture = preload("res://art/_shared/touch_button_action_main_skip.png")

enum Mode {
	UI_MENU,
	CUTSCENE,
	GAMEPLAY,
	GAMEPLAY_DPAD_ONLY,
}

var mode: Mode:
	set(value):
		mode = value
		_on_mode_set()

var _touch_screen_controller: TouchScreenController


func _init() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS


func _ready() -> void:
	if DisplayServer.is_touchscreen_available():
		_touch_screen_controller = TouchScreenControllerScn.instantiate()
		add_child(_touch_screen_controller)
	
		Input.joy_connection_changed.connect(_on_joy_connection_changed)
		# Doesn't seem to be necessary to call _update_touch_controller_visibility here.
		# _on_joy_connection_changed is called when the game starts (on desktop)
		# or when the user presses a button or moves a stick for the first time
		# after the game starts (on web).


func _configure_controller_for_mode(new_mode: Mode) -> void:
	if not _touch_screen_controller:
		return
	
	match new_mode:
		Mode.UI_MENU:
			_touch_screen_controller.main_action_button_texture = \
					_button_action_main_accept_texture
			_touch_screen_controller.action_button = &"ui_accept"
			_touch_screen_controller.action_down = &"ui_down"
			_touch_screen_controller.action_left = &"ui_left"
			_touch_screen_controller.action_right = &"ui_right"
			_touch_screen_controller.action_up = &"ui_up"
			_touch_screen_controller.hide_main_action_button = false
			_touch_screen_controller.hide_pause_button = true
		Mode.CUTSCENE:
			_touch_screen_controller.main_action_button_texture = \
					_button_action_main_skip_texture
			_touch_screen_controller.action_button = &"skip_cutscene"
			_touch_screen_controller.action_down = &"ui_down"
			_touch_screen_controller.action_left = &"ui_left"
			_touch_screen_controller.action_right = &"ui_right"
			_touch_screen_controller.action_up = &"ui_up"
			_touch_screen_controller.hide_main_action_button = false
			_touch_screen_controller.hide_pause_button = true
		Mode.GAMEPLAY:
			_touch_screen_controller.main_action_button_texture = \
					_button_action_main_fire_texture
			_touch_screen_controller.action_button = &"fire"
			_touch_screen_controller.action_down = &"move_down"
			_touch_screen_controller.action_left = &"move_left"
			_touch_screen_controller.action_right = &"move_right"
			_touch_screen_controller.action_up = &"move_up"
			_touch_screen_controller.hide_main_action_button = false
			_touch_screen_controller.hide_pause_button = false
		Mode.GAMEPLAY_DPAD_ONLY:
			_touch_screen_controller.main_action_button_texture = null
			# action_button cannot be null, so I'll just set it to whatever...
			_touch_screen_controller.action_button = &"fire"
			_touch_screen_controller.action_down = &"move_down"
			_touch_screen_controller.action_left = &"move_left"
			_touch_screen_controller.action_right = &"move_right"
			_touch_screen_controller.action_up = &"move_up"
			_touch_screen_controller.hide_main_action_button = true
			_touch_screen_controller.hide_pause_button = false


func _is_any_joypad_connected() -> bool:
	return not Input.get_connected_joypads().is_empty()


func _update_touch_controller_visibility() -> void:
	if _touch_screen_controller:
		_touch_screen_controller.visible = not _is_any_joypad_connected()


func _on_mode_set() -> void:
	if is_node_ready():
		_configure_controller_for_mode(mode)


func _on_joy_connection_changed(_device: int, _connected: bool) -> void:
	_update_touch_controller_visibility()
