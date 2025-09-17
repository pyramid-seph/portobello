extends Node2D


@export_custom(PROPERTY_HINT_INPUT_NAME, "show_builtin")
var action_left: StringName = &"ui_left":
	set(value):
		action_left = value
		_on_action_left_set()
@export_custom(PROPERTY_HINT_INPUT_NAME, "show_builtin")
var action_right: StringName = &"ui_right":
	set(value):
		action_right = value
		_on_action_right_set()
@export_custom(PROPERTY_HINT_INPUT_NAME, "show_builtin")
var action_up: StringName = &"ui_up":
	set(value):
		action_up = value
		_on_action_up_set()
@export_custom(PROPERTY_HINT_INPUT_NAME, "show_builtin")
var action_down: StringName = &"ui_down":
	set(value):
		action_down = value
		_on_action_down_set()
@export_custom(PROPERTY_HINT_INPUT_NAME, "show_builtin")
var action_button: StringName = &"ui_accept":
	set(value):
		action_button = value
		_on_action_button_set()
@export_custom(PROPERTY_HINT_INPUT_NAME, "show_builtin")
var secondary_action_button: StringName = &"ui_cancel":
	set(value):
		secondary_action_button = value
		_on_secondary_action_button_set()
@export_custom(PROPERTY_HINT_INPUT_NAME, "show_builtin")
var action_pause: StringName = &"pause":
	set(value):
		action_pause = value
		_on_action_pause_set()
@export var main_action_button_texture: Texture2D:
	set(value):
		main_action_button_texture = value
		_on_main_action_button_texture_set()
@export var secondary_action_button_texture: Texture2D:
	set(value):
		secondary_action_button_texture = value
		_on_secondary_action_button_texture_set()
@export var hide_main_action_button: bool = true:
	set(value):
		hide_main_action_button = value
		_on_hide_main_action_button_set()
@export var hide_secondary_action_button: bool = true:
	set(value):
		hide_secondary_action_button = value
		_on_hide_secondary_action_button_set()
@export var hide_pause_button: bool:
	set(value):
		hide_pause_button = value
		_on_hide_pause_button_set()

@onready var _pause_button: TouchScreenButton = $PauseButton
@onready var _main_action_button: TouchScreenButton = $MainActionButton
@onready var _main_action_button_sprite: Sprite2D = $MainActionButton/Sprite2D
@onready var _secondary_action_button: TouchScreenButton = $SecondaryActionButton
@onready var _secondary_action_button_sprite: Sprite2D = $SecondaryActionButton/Sprite2D
@onready var _dpad_left_button: TouchScreenButton = $Dpad/LeftButton
@onready var _dpad_right_button: TouchScreenButton = $Dpad/RightButton
@onready var _dpad_up_button: TouchScreenButton = $Dpad/UpButton
@onready var _dpad_down_button: TouchScreenButton = $Dpad/DownButton


func _ready() -> void:
	_on_action_left_set()
	_on_action_right_set()
	_on_action_up_set()
	_on_action_down_set()
	_on_action_button_set()
	_on_secondary_action_button_set()
	_on_action_pause_set()
	_on_main_action_button_texture_set()
	_on_secondary_action_button_texture_set()
	_on_hide_pause_button_set()
	top_level = true


func _on_action_left_set() -> void:
	if is_node_ready():
		if _dpad_left_button.action:
			Input.action_release(_dpad_left_button.action)
		_dpad_left_button.action = action_left


func _on_action_right_set() -> void:
	if is_node_ready():
		if _dpad_right_button.action:
			Input.action_release(_dpad_right_button.action)
		_dpad_right_button.action = action_right


func _on_action_up_set() -> void:
	if is_node_ready():
		if _dpad_up_button.action:
			Input.action_release(_dpad_up_button.action)
		_dpad_up_button.action = action_up


func _on_action_down_set() -> void:
	if is_node_ready():
		if _dpad_down_button.action:
			Input.action_release(_dpad_down_button.action)
		_dpad_down_button.action = action_down


func _on_action_button_set() -> void:
	if is_node_ready():
		if _main_action_button.action:
			Input.action_release(_main_action_button.action)
		_main_action_button.action = action_button


func _on_secondary_action_button_set() -> void:
	if is_node_ready():
		if _secondary_action_button.action:
			Input.action_release(_secondary_action_button.action)
		_secondary_action_button.action = secondary_action_button


func _on_action_pause_set() -> void:
	if is_node_ready():
		if _pause_button.action:
			Input.action_release(_pause_button.action)
		_pause_button.action = action_pause


func _on_hide_main_action_button_set() -> void:
	if is_node_ready():
		_main_action_button.visible = !hide_main_action_button


func _on_hide_secondary_action_button_set() -> void:
	if is_node_ready():
		_secondary_action_button.visible = !hide_secondary_action_button


func _on_main_action_button_texture_set() -> void:
	if is_node_ready():
		_main_action_button_sprite.texture = main_action_button_texture


func _on_secondary_action_button_texture_set() -> void:
	if is_node_ready():
		_secondary_action_button_sprite.texture = secondary_action_button_texture


func _on_hide_pause_button_set() -> void:
	if is_node_ready():
		_pause_button.visible = !hide_pause_button
