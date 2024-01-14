@tool
extends Node

@export var root_path: Node:
	set(value):
		root_path = value
		update_configuration_warnings()
@export var move_sound: AudioStream
@export var pressed_sound: AudioStream

var _curr_menu: Node:
	set(value):
		_curr_menu = value
		print("_curr_menu: %s" % _curr_menu.name if _curr_menu else "null")


func _ready() -> void:
	if Engine.is_editor_hint():
		return
	
	if not root_path:
		print("root_path is required. Aborting UI sounds installation.")
		return
	
	_install_focus_change_sounds()
	_install_control_ui_sounds(root_path)


func _get_configuration_warnings() -> PackedStringArray:
	var warnings: PackedStringArray = []
	if not root_path:
		warnings.append("Root path is required.")
	return warnings


func _play_sound(sound: AudioStream) -> void:
	if sound:
		SoundManager.play_ui_sound(sound)


func _connect_signals(node: Control) -> void:
	if not node:
		return
	
	if node is Button:
		node.pressed.connect(_play_sound.bind(pressed_sound))
	elif node is HSelector:
		node.selected.connect(_on_h_selector_selected)
		node.current_option_index_changed.connect(
				_on_h_selector_current_option_index_changed.bind(node))


func _install_control_ui_sounds(parent_node: Node) -> void:
	if not parent_node or parent_node == self:
		return
	
	for child_node: Node in parent_node.get_children():
		if child_node as Control:
			_connect_signals(child_node)
		_install_control_ui_sounds(child_node)


func _install_focus_change_sounds() -> void:
	get_viewport().gui_focus_changed.connect(_on_gui_focus_changed)


func _on_menu_dismissed(dismissed_menu: Node) -> void:
	# XXX Checking equality in case _on_gui_focus_changed 
	#  is called before _on_menu_dismissed on the same frame.
	if dismissed_menu == _curr_menu:
		_curr_menu = null


func _on_gui_focus_changed(node: Control) -> void:
	if not (node is Button or node is HSelector):
		return
	
	if node.owner == _curr_menu:
		_play_sound(move_sound)
		return
	
	if _curr_menu and _curr_menu.has_signal("visibility_changed"):
		Utils.safe_disconnect(_curr_menu.visibility_changed, _on_menu_dismissed)
		
	_curr_menu = node.owner
	if _curr_menu.has_signal("visibility_changed") and \
			not _curr_menu.is_connected("visibility_changed", _on_menu_dismissed):
		_curr_menu.visibility_changed.connect(
				_on_menu_dismissed.bind(_curr_menu), CONNECT_ONE_SHOT)


func _on_h_selector_current_option_index_changed(_index, node: Control) -> void:
	if node.is_visible_in_tree():
		_play_sound(move_sound)


func _on_h_selector_selected(_value) -> void:
	_play_sound(pressed_sound)
