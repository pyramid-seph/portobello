class_name UiSounds
extends Node


@export var _root_path: NodePath = ^".."
@export var _max_depth: int = 16:
	set(value):
		_max_depth = maxi(value, 1)
@export var move_sound: AudioStream
@export var pressed_sound: AudioStream
@export var pressed_disabled_sound: AudioStream


var _skip_focus_sound: bool


func _ready() -> void:
	var root_node: Node = get_node(_root_path)
	_install_control_ui_sounds(root_node)


## Call this method instead of node.grab_focus() to
## focus node without playing the focus sound.
func focus_node_no_sound(node: Control) -> void:
	if node:
		_skip_focus_sound = true
		node.grab_focus()
		_skip_focus_sound = false


func _play_sound(sound: AudioStream) -> void:
	if sound:
		SoundManager.play_ui_sound(sound)


func _connect_signals(node: Control) -> void:
	if not node:
		return
	
	if node is Button:
		Utils.safe_connect(node.pressed, _play_sound.bind(pressed_sound))
		Utils.safe_connect(node.focus_entered, _on_focus_entered)
	elif node is HSelector:
		Utils.safe_connect(node.selected, _on_h_selector_selected)
		Utils.safe_connect(node.current_option_index_changed,
				_on_h_selector_current_option_index_changed.bind(node))
		Utils.safe_connect(node.focus_entered, _on_focus_entered)
		Utils.safe_connect(node.selected_disabled_option, 
				_on_h_selector_selected_disabled_option)


func _install_control_ui_sounds(parent_node: Node, depth: int = 0) -> void:
	if not parent_node or parent_node is UiSounds:
		if parent_node != self:
			var parent_node_parent: Node = parent_node.get_parent()
			if parent_node_parent:
				Log.w("Another UiSound is in: ", parent_node_parent.name)
		return
	
	if depth >= _max_depth:
		Log.w("%s has reached max depth (%s)" % [name, _max_depth])
		return
	
	for child_node: Node in parent_node.get_children():
		_connect_signals(child_node as Control)
		_install_control_ui_sounds(child_node, depth + 1)


func _on_focus_entered() -> void:
	if not _skip_focus_sound:
		_play_sound(move_sound)


func _on_h_selector_current_option_index_changed(_index, node: Control) -> void:
	if node.is_visible_in_tree():
		_play_sound(move_sound)


func _on_h_selector_selected(_value) -> void:
	_play_sound(pressed_sound)


func _on_h_selector_selected_disabled_option() -> void:
	_play_sound(pressed_disabled_sound)
