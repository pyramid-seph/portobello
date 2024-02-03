extends Node2D


@export var action_left: StringName = &"ui_left":
	set(value):
		action_left = value
		_on_action_left_set()
@export var action_right: StringName = &"ui_right":
	set(value):
		action_right = value
		_on_action_right_set()
@export var action_up: StringName = &"ui_up":
	set(value):
		action_up = value
		_on_action_up_set()
@export var action_down: StringName = &"ui_down":
	set(value):
		action_down = value
		_on_action_down_set()
@export var hide_main_action_button: bool:
	set(value):
		hide_main_action_button = value
		_on_hide_main_action_button_set()
@export var main_action_button_texture: Texture2D:
	set(value):
		main_action_button_texture = value
		_on_main_action_button_texture_set()
@export var action_button: StringName = &"ui_accept":
	set(value):
		action_button = value
		_on_action_button_set()
@export var hide_pause_button: bool:
	set(value):
		hide_pause_button = value
		_on_hide_pause_button_set()
		
@onready var _pause_button: TouchScreenButton = $PauseButton
@onready var _main_action_button: TouchScreenButton = $MainActionButton
@onready var _main_action_button_sprite: Sprite2D = $MainActionButton/Sprite2D
@onready var _dpad_left_button: TouchScreenButton = $Dpad/LeftButton
@onready var _dpad_right_button: TouchScreenButton = $Dpad/RightButton
@onready var _dpad_up_button: TouchScreenButton = $Dpad/UpButton
@onready var _dpad_down_button: TouchScreenButton = $Dpad/DownButton


func _ready() -> void:
	_on_action_left_set()
	_on_action_right_set()
	_on_action_up_set()
	_on_action_down_set()
	_on_main_action_button_texture_set()
	_on_action_button_set()
	_on_hide_pause_button_set()
	top_level = true


func _on_action_left_set() -> void:
	if is_node_ready():
		_dpad_left_button.action = action_left


func _on_action_right_set() -> void:
	if is_node_ready():
		_dpad_right_button.action = action_right


func _on_action_up_set() -> void:
	if is_node_ready():
		_dpad_up_button.action = action_up


func _on_action_down_set() -> void:
	if is_node_ready():
		_dpad_down_button.action = action_down


func _on_hide_main_action_button_set() -> void:
	if is_node_ready():
		_main_action_button.visible = !hide_main_action_button


func _on_main_action_button_texture_set() -> void:
	if is_node_ready():
		_main_action_button_sprite.texture = main_action_button_texture


func _on_action_button_set() -> void:
	if is_node_ready():
		_main_action_button.action = action_button


func _on_hide_pause_button_set() -> void:
	if is_node_ready():
		_pause_button.visible = !hide_pause_button
